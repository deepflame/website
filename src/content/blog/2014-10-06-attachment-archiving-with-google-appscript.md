---
title: Automated attachment archiving with Google Apps
date: 2014-10-06
tags: ["google", "appscript", "gmail", "drive", "javascript"]
---

For a long time I have been looking for accounting software or a small ERP system to run my business. It should have some basic functionality like storing all bills and invoices. We are using Google Apps for mail and documents, so it would be great if the software would integrate here as well.
Some time ago I stumbled over Google AppScript - a way to automate simple business processes within Google Apps. I ditched the idea of a separate accounting software and wrote an AppScript to cover one item of our wishlist: simple archiving of documents in the cloud.

READMORE

## Use Case

We receive bills from service providers and need to send out invoices to our customers. All (or most) of these documents will be sent as a PDF file attachment.
When we receive a bill now we will set a specific label to the email thread. After some minutes the attachment will be copied to a folder we specified, fully renamed to the format we wanted.

## The Code

If you are completely new to Google AppScript then you are not lost. There is good [documentation](https://developers.google.com/apps-script/) out there. The great thing is that all AppScripts are pure JavaScript executed on Google server infrastructure. If you are a web developer you do not have a new language to learn.

```javascript
/* configuration */
var CONFIGS = [{
  label: 'accounting/bills',
  dest: 'Accounting/IN/bills',
}, {
  label: 'accounting/invoices',
  dest: 'Accounting/OUT/invoices'
}];
var LABEL_DONE = 'script/done';

/* main function */
function run() {
  for (var c = 0; c < CONFIGS.length; c++) {
    var config = CONFIGS[c];
    moveMailAttachmentsToDriveFolder(config.label, config.dest);
  }
}

/* helper functions */
var moveMailAttachmentsToDriveFolder = function(labelDone) {

  var markMailThreadAsDone = function (thread) {
    var mailLabel = getMailLabelByName(labelDone);
    thread.addLabel(mailLabel);
  }

  var getMailLabelByName = function (name) {
    var label = GmailApp.getUserLabelByName(name);
    if (!label) {
      label = GmailApp.createLabel(name);
    }
    return label;
  }

  var getDriveFolder = function (name) {
    var folder;
    try {
      folder = DocsList.getFolder(name)
    } catch(e) {
      // TODO: should create subfolders successively
      folder = DocsList.createFolder(name);
    }
    return folder;
  }

  var getDatePrefix = function (date) {
    // inspired by Stackoverflow
    var yy = date.getFullYear().toString().slice(-2);
    var mm = (date.getMonth()+1).toString(); // getMonth() is zero-based
    var dd  = date.getDate().toString();
    return yy + (mm[1]?mm:"0"+mm[0]) + (dd[1]?dd:"0"+dd[0]); // padding
  }

  var main = function (label, destFolder) {
    var threads = GmailApp.search('label:' + label + ' -label:' + labelDone);
    Logger.log('searched');

    // iterate over threads
    for (var t = 0; t < threads.length; t++) {
      var thread = threads[t];
      var messages = thread.getMessages();

      // iterate over messages
      for (var m = 0; m < messages.length; m++) {
        var message = messages[m];

        // iterate over attachments
        var attachments = message.getAttachments();
        for (var a = 0; a < attachments.length; a++) {
          var attachment = attachments[a];

          // copy attachment file
          var attachmentBlob = attachment.copyBlob();
          var attachmentName = attachmentBlob.getName();

          // rename file
          var datePrefix = getDatePrefix(message.getDate());
          var senderDomain = message.getFrom().replace(/(.+)@(\w+).(\w+)>?/, "$2");
          var newAttachmentName = datePrefix + ' ' + senderDomain + ' ' + attachmentName;
          attachmentBlob.setName(newAttachmentName);

          // put file on Drive
          var folder = getDriveFolder(destFolder);
          var file = folder.createFile(attachmentBlob);
        }
      }

      markMailThreadAsDone(thread);
    }
  }
  return main;
}(LABEL_DONE);
```

## Usage

First step is to set the configuration. You need to specify the mail labels you want to process and you need to set the destination where you want your attachments to be put on Google Drive.

You may check how the resulting file will be renamed before it will be put on Google Drive. Currently the format is `<date_yymmdd> <from_domain> <original_name>.<ext>`

If you want to run the script automatically make sure to enable the time-driven trigger for it.

## The Future

This script could need some more polishing and attention. This is my _incomplete_ wishlist:

1. generate output folders properly (slashes become dashes now and do not create subfolders)
1. configurable output file name
1. configuration in Google Spreadsheet (not sure about this one though)

## Final Thoughts

I am sure that we will use AppScript more. It just makes sense for web developers and Google Apps users that we both are. The Google AppScript API is well documented and easy to learn.
We will see how far it goes but I could think that it is possible to support many processes of a small to medium business just with AppScript. There are contacts, calendars, mail, documents, sites and some more. All things that can be used to integrate into a custom workflow.

## Links

- https://developers.google.com/apps-script/
- http://www.googleappsscript.org/ (useful unofficial example site)