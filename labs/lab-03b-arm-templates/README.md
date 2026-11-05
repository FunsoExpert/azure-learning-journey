# Lab 03b: Manage Azure Resources by Using ARM Templates

**Date:** 5 Nov 2026
**Resource group:** az104-rg3
**Region:** <your region> (the lab uses East US, but my subscription only allows certain regions)

## What this lab is about
The goal is to stop clicking through the portal and deploy resources from a template instead. I deploy the same kind of managed disk five different ways: portal, custom template, PowerShell, CLI and Bicep. It's a small resource, but the point is that the process is repeatable.

## Task 1: Create a disk and export the template
I created a managed disk called `az104-disk1` in `az104-rg3` (Standard HDD, 32 GiB). Then I went to Automation > Export template and downloaded both files.

What I noticed:
- `template.json` holds the actual disk definition: type, SKU, size and location.
- `parameters.json` is much shorter. It only holds the disk name, and the value is `null` until you fill it in.

![Disk created](screenshots/01-disk-created.png)
![Export template](screenshots/02-export-template.png)

## Task 2: Edit the template and redeploy
<Fill in once it's done: what I changed (parameter renamed to `disk_name`, disk name to `az104-disk2`, location to my region), and how the deployment went.>

### Where I got stuck
When I loaded my file into the template editor, I got "This is not a valid template" and the editor showed Resources (0). I'd downloaded the Parameters tab content by mistake and saved it as `template.json`. The export page has two tabs, Template and Parameters, and Download saves whichever one you're looking at.

How I fixed it: I went back to the export page, switched to the Template tab, downloaded again, and opened both files in Notepad before using them. The real template is long and has a `resources` array, and the parameters file is the short one.

Lesson: check what a file contains before you load it, not after the portal complains.

## Task 3: Deploy with Azure PowerShell
<To do>

## Task 4: Deploy with Azure CLI
<To do>

## Task 5: Deploy with Bicep
<To do. Note: the lab changes the SKU to StandardSSD_LRS, but my sandbox only allows Standard_LRS, so I kept Standard_LRS.>

## What I took away
<Write these after you finish. Two or three lines, in your own words, on what the exported template gave you and how the five methods compare.>

## Cleanup
<Delete az104-rg3 once the lab is done.>