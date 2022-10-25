#!/usr/bin/python

## *** I am not using this code as it seems to be ineffective ***
## The combined html file works very slow...

# Create a a combined html file for the output of the fMRIprep

import os
import glob

# Parameters:
# -------------------
# files and directories:
datadir = '/export2/DATA/HIS/HIS_server/BIDS/derivatives/fmriprep/'
outdir  = "/export2/DATA/HIS/HIS_server/analysis/QA/fMRIprep/"
outfile = outdir + "fMRIprep_QA.html"

# run the procedure
# --------------------
# delete older files
print('\n** QA fMRIprep (combining report htmls to fMRIprep_QA.html)')
os.system("rm %s"%(outfile))
os.system("rm -rf " + outdir + ' sub-*/')
os.system("mkdir "  + outdir)

all_subjects = sorted(glob.glob(datadir + 'sub-*/'))

isErrorLogs = False
isWarningLogs = False
f = open(outfile, "w")
for file in list(all_subjects):
  subject = file.split('/')[-2]
  main_html = datadir + subject + ".html"
  figures_source_dir = datadir + subject + '/figures'
  figures_out_dir = outdir + subject + '/figures'
  # write the combined html
  f.write("<p>=================" + subject + "===========================\n")
  with open(main_html, 'r') as content_file:
      content = content_file.read()
  f.write(content)
  # copy the relevant figures
  os.system("mkdir -p " + figures_out_dir)
  os.system("cp -r " + figures_source_dir + "/* " + figures_out_dir)

  # check the log file for errors:

  if os.popen("grep -i 'No errors to report' " + main_html).read():
    pass
  elif os.popen("grep -i 'error' " + main_html).read():
    print('-- ERROR in the log of the fmriprep: ' + file)
    print(os.popen("grep -i 'error' " + main_html).read())
    isErrorLogs = True
  if os.popen("grep -i 'warning' " + main_html).read():
    print('-- WARNING in the log of the fmriprep: ' + file)
    print(os.popen("grep -i 'warning' " + main_html).read())
    isWarningLogs = True
f.close()

print('** QA fMRIprep (creating fMRIprep_QA.html) COMPLETED.')
if isErrorLogs:
    print('\n *** THERE ARE LOG FILES WITH ERRORS TO EXAMINE *** ')
if isWarningLogs:
    print('\n *** THERE ARE LOG FILES WITH WARNINGS TO EXAMINE *** ')
