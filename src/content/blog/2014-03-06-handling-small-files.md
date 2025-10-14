---
title: Handling small files - Lessons learned
date: 2014-03-06
tags: ["linux", "sysadm", "files"]
published: true
---

Did you ever have to transfer millions of small files on Linux? Here is our story and the the lessons we learned when migrating them to another server.

READMORE

## Transferring them quickly

How do you transfer millions of files quickly if you only have limited time?
First we tried rsync over ssh and nfs. That did not give the desired results.

A Google search revealed the following method. tar over ssh!

```shell
$ tar c <directory> | ssh <hostname> \"cd <destination> && tar x\""
```

This streams the files over ssh to the other server and unpacks them again. Data compression was not necessary in our case since the files were compressed already.

Our files were in lots of subdirectories. So we decided to write a script to transfer the files in increments.

```shell
#!/bin/bash

SERVER=<hostname>

current_dir=`pwd`
dirs=( $(ls) )

for d in "${dirs[@]}"
do
	cmd="tar c $d | ssh $SERVER \"cd $current_dir && tar x\""
	echo $cmd
	$cmd
done
```

Please note that this script is only working if the old and new machine have the same directory structure. Otherwise you need to modify it a bit.

Great! Now we knew how to transfer them quickly and we started the script in the evening and hoped that it would be finished the next morning.

## Running out of inodes

Arriving in the office again the next day we found a lot of error messages that the files could not be written. `df` showed that the disk was not full, but that we ran out of inodes ( `df -i` ).
How could that have happened? I thought it was the same setup? Running

```shell
$ tune2fs -l <device>
```

gave us some clues. It turned out that the new server was running RHEL 6.4 and was using ext4, the old one was using ext3.
Our ext4 settings were different from ext3 and we had halv the inodes available.
Bummer!

The solution was to reformat the whole partition. Increasing the inode count afterwards is not possible.

```shell
$ mkfs.ext4 -T small <device>
```

This uses the 'small' template which is defined in the `/etc/mke2fs.conf`. Here is what it says:

```conf
[defaults]
	base_features = sparse_super,filetype,resize_inode,dir_index,ext_attr
	blocksize = 4096
	inode_size = 256
	inode_ratio = 16384

[fs_types]
	ext3 = {
		features = has_journal
	}
	ext4 = {
		features = has_journal,extent,huge_file,flex_bg,uninit_bg,dir_nlink,extra_isize
		inode_size = 256
	}
	small = {
		blocksize = 1024
		inode_size = 128
		inode_ratio = 4096
	}
```

The fs_type settings for "small" are apparently way different from the defaults on top.

The second attempt to transfer the files went well! After all we had quite some savings in disk space. The files now consumed 40GB compared to 80GB before. The reduced blocksize made this possible.

Lesson learned here is to check the inode count _before_ transferring the files.