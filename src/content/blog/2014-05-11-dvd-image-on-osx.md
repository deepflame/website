---
title: Creating a CD/DVD Image on the OSX command line
date: 2014-05-11
tags: ["osx", "commandline", "files"]
---

Yesterday I wanted to install Windows 7 in VirtualBox on OSX. I did not have an image of the installation medium, so I used the physical disk I had and put it into the external usb drive.
Strangely the disk showed up in the Finder but could not be seen in VirtualBox. Neither "Disk Utility" showed the disk (?).

Following are the steps used to make a DVD image from the command line with `dd` on OSX.

READMORE

### 0. Prerequisites

Make sure the disk is inserted and you have a commandline open...

### 1. Get device path of the optical drive

The `dd` command needs to have the device name like `/dev/disk?` to work properly.
To retrieve the path execute

```shell
$ diskutil list
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *240.1 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:                  Apple_HFS Macintosh HD            239.2 GB   disk0s2
   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
/dev/disk1
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *320.1 GB   disk1
   1:                        EFI EFI                     209.7 MB   disk1s1
   2:                  Apple_HFS Storage HD              319.2 GB   disk1s2
/dev/disk2
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:                            GRMCHPXFRER_EN_DVD     *3.2 GB     disk2
```

You see in the output above that the path in my case is `/dev/disk2`. This is because I have 2 harddisks in my Mac. If you only have one, then your path is most probably `/dev/disk1`.
Please adjust the following references according to the drive letter you got.

### 2. Unmount drive

If we ran the `dd` command now it would complain that the device is busy. We need to unmount it first.

```shell
$ diskutil unmountDisk /dev/disk2
```

### 3. Copy disk

Now we are free to run `dd`.

```shell
$ dd if=/dev/disk2 of=~/Desktop/image.iso bs=2048 conv=noerror,sync
```

- __if__ sets the input file
- __of__ sets the output file
- __bs=2048__ sets the blocksize to read and write to 2048 (CD block size, DVD is similar)
- __conv=noerror__ will continue even if there are read errors
- __conv=sync__ will fill up missing input data with NUL bytes

This will read the whole disk and dump the contents to the Desktop folder as `image.iso`. In our case it took a bit less than 10 minutes from an external usb drive.

At the end you will get an output similar to this:

```shell
1574554+0 records in
1574554+0 records out
3224686592 bytes transferred in 577.105259 secs (5587692 bytes/sec)
```

### 4. Mount drive again

If you want to let the disk appear again in the Finder you have to mount it again

```shell
$ diskutil mountDisk /dev/disk2
```