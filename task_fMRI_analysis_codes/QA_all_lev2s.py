#!/usr/bin/python

# Create a level 2 QA html file with a dedicated library for the png's.
# Created by Jeanette Mumford, adapted by Rani Gera, February 2020 for the HIS study.
# A test for errors in the log files was added.

import os
import glob
import sys

# Parameters:
# -------------------
# files and directories:
model   = sys.argv[1]
datadir = '/export2/DATA/HIS/HIS_server/analysis/task_fMRI_data/'
outdir  = "/export2/DATA/HIS/HIS_server/analysis/QA/"
outfile = outdir + "lev2_model" + model + "_QA.html"
associatedPngFilesDir = outdir + "lev2_png_files_model_" + model

# run the procedure
# --------------------
# delete older files
print('\n** QA second level (creating ' + 'lev2_model' + model + '_QA.html)')
os.system("rm %s"%(outfile))
os.system("rm -rf " + associatedPngFilesDir)
os.system("mkdir "  + associatedPngFilesDir)

all_gfeats = sorted(glob.glob(datadir + 'sub-*/lev2_models/model' + model + '/sub-*_*.gfeat'))
analysesNames = list(set([x.split('/')[-1][x.split('/')[-1].find('_') + 1:x.split('/')[-1].find('.gfeat')] for x in all_gfeats]))

isErrorLogs = False
isWarningLogs = False
f = open(outfile, "w")
for analysisName in analysesNames:
    # make directory for the analysis name (if not already exists):
    os.system("mkdir -p " + associatedPngFilesDir + '/' + analysisName)
    # get analysis-specific gfeats:
    analysis_gfeats = sorted(glob.glob(datadir + 'sub-*/lev2_models/model' + model + '/sub-*' + analysisName + '*.gfeat'))
    for gfeat_dir in analysis_gfeats:
        # get subject
        sub = gfeat_dir.split('/')[-1].split('_')[0]
        f.write("<p>================================ " + sub + " - " + analysisName + " ================================")
        f.write("<p>")
        f.write("<p>%s" % (gfeat_dir))
        f.write("<p>")
        f.write("<IMG SRC=\"lev2_png_files_model_" + model + "/" + analysisName + "/%s.masksum_overlay.png\">" % (gfeat_dir.replace("/", "_")))
        f.write("<p>")
        f.write("<IMG SRC=\"lev2_png_files_model_" + model + "/" + analysisName + "/%s.maskunique_overlay.png\">" % (gfeat_dir.replace("/", "_")))
        f.write("<p>")
        os.system(
            "cp %s/inputreg/masksum_overlay.png " % (gfeat_dir) + associatedPngFilesDir + "/" + analysisName + "/%s.masksum_overlay.png" % (
                gfeat_dir.replace("/", "_")))
        os.system(
            "cp %s/inputreg/maskunique_overlay.png " % (gfeat_dir) + associatedPngFilesDir + "/" + analysisName + "/%s.maskunique_overlay.png" % (
                gfeat_dir.replace("/", "_")))

        # check the log file for errors:
        if os.popen("grep -i 'error' " + gfeat_dir + "/report_log.html").read():
            print('-- ERROR in the log of the second level gfeat: ' + gfeat_dir)
            print(os.popen("grep -i 'error' " + gfeat_dir + "/report_log.html").read())
            isErrorLogs = True
        if os.popen("grep -i 'warning' " + gfeat_dir + "/report_log.html").read():
            print('-- WARNING in the log of the second level gfeat: ' + gfeat_dir)
            print(os.popen("grep -i 'warning' " + gfeat_dir + "/report_log.html").read())
            isWarningLogs = True
f.close()

print('** QA second level (creating lev2_model' + model + '_QA.html) COMPLETED.')
if isErrorLogs:
    print('\n *** THERE ARE LOG FILES WITH ERRORS TO EXAMINE *** ')
if isWarningLogs:
    print('\n *** THERE ARE LOG FILES WITH WARNINGS TO EXAMINE *** ')
