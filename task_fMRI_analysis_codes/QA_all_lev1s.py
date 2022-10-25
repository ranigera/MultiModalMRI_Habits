#!/usr/bin/python

# Create a level 1 QA html file with a dedicated library for the png's.
# Created by Jeanette Mumford, adapted by Rani Gera, February 2020 for the HIS study.
# A test for errors in the log files was added.
# * because I used fMRIprep the registration parts here are irrelevant and thus commented off.
# The argument passed through the bash is the model (adjusted for that by Rani in Jan 2022)

import os
import glob
import sys

# Parameters:
# -------------------
# files and directories:
model   = sys.argv[1]
datadir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/'
outdir  = "/export2/DATA/HIS/HIS_server/analysis/QA/"
outfile = outdir + "lev1_model" + model + "_QA.html"
associatedPngFilesDir = outdir + "lev1_png_files_model_" + model

# run the procedure
# --------------------
# delete older files
print('\n** QA first level (creating ' + 'lev1_model' + model + '_QA.html)')
os.system("rm %s"%(outfile))
os.system("rm -rf " + associatedPngFilesDir)
os.system("mkdir "  + associatedPngFilesDir)

all_feats = sorted(glob.glob(datadir + 'sub-*/ses-*/models/model' + model + '/sub-*_ses-*_task-*.feat/'))

isErrorLogs = False
isWarningLogs = False
f = open(outfile, "w")
for file in list(all_feats):
  f.write("<p>============================================")
  f.write("<p>%s"%(file))

  f.write("<IMG SRC=\"lev1_png_files_model_" + model + "/%s.design.png\">"%(file.replace("/", "_")))
  f.write("<IMG SRC=\"lev1_png_files_model_" + model + "/%s.design_cov.png\" >"%(file.replace("/", "_")))
  #f.write("<IMG SRC=\"lev1_png_files/%s.disp.png\">"%(file.replace("/", "_")))
  #f.write("<IMG SRC=\"lev1_png_files/%s.trans.png\" >"%(file.replace("/","_")))
  #f.write("<p><IMG SRC=\"lev1_png_files/%s.example_func2highres.png\" WIDTH=1200>"%(file.replace("/","_")))
  #f.write("<p><IMG SRC=\"lev1_png_files/%s.example_func2standard.png\" WIDTH=1200>"%(file.replace("/","_")))
  #f.write("<p><IMG SRC=\"lev1_png_files/%s.highres2standard.png\" WIDTH=1200>"%(file.replace("/","_")))

  os.system("cp %sdesign.png "%(file) + associatedPngFilesDir + "/%s.design.png"%(file.replace("/","_")))
  os.system("cp %sdesign_cov.png "%(file) + associatedPngFilesDir + "/%s.design_cov.png"%(file.replace("/","_")))
  #os.system("cp %smc/disp.png "%(file) + associatedPngFilesDir + "/%s.disp.png"%(file.replace("/","_")))
  #os.system("cp %smc/trans.png "%(file) + associatedPngFilesDir + "/%s.trans.png"%(file.replace("/", "_")))
  #os.system("cp %sreg/example_func2highres.png "%(file) + associatedPngFilesDir + "/%s.example_func2highres.png"%(file.replace("/","_")))
  #os.system("cp %sreg/example_func2standard.png "%(file) + associatedPngFilesDir + "/%s.example_func2standard.png"%(file.replace("/","_")))
  #os.system("cp %sreg/highres2standard.png "%(file) + associatedPngFilesDir + "/%s.highres2standard.png"%(file.replace("/","_")))

  # check the log file for errors:
  if os.popen("grep -i 'error' " + file + "report_log.html").read():
    print('-- ERROR in the log of the first level feat: ' + file)
    print(os.popen("grep -i 'error' " + file + "report_log.html").read())
    isErrorLogs = True
  if os.popen("grep -i 'warning' " + file + "report_log.html").read():
    print('-- WARNING in the log of the first level feat: ' + file)
    print(os.popen("grep -i 'warning' " + file + "report_log.html").read())
    isWarningLogs = True
f.close()

print('** QA first level (creating lev1_QA.html) for model ' + model + ' is COMPLETED.')
if isErrorLogs:
    print('\n *** THERE ARE LOG FILES WITH ERRORS TO EXAMINE *** ')
if isWarningLogs:
    print('\n *** THERE ARE LOG FILES WITH WARNINGS TO EXAMINE *** ')

