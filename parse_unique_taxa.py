#Script for finding unique or shared taxa across samples.... must group together feature table (mean-ceiling in spider case) and generate taxa plots from grouped table - or replicates end up messing up what is unique or not
#Sdunaj version, based off BBettencourt's orignal script
#Update ranges to match your taxa table being read into this script
#Transpose Taxa table prior to running through script and delete last few rows with extra sample map / meta-date file details/ columns (columns before transposing)
#!/usr/bin/python

import re

def main():

    unique = {}  # keyed by Taxa reads, val = sample (tissue) name if never seen elsewhere
    shared = {}  # keyed by Taxa reads, "YES" if found in all samples (tissues)

    f = open ('level-6_TaxaAll_noMock_GROUPED_MEAN.csv','rU')
    lines = f.readlines()

    headers = lines[0].rstrip('\n')
    header_items = headers.split(',')
    print header_items
    lines.pop(0)  # get rid of header line

    
    for thisLine in lines:   # look at each line, see if OTU is unique to one tissue or shared among ALL
        thisLine = thisLine.rstrip('\n')
        items = thisLine.split(',')  
        Taxa = items[0]
        
        unique[Taxa] = "new"
        shared[Taxa] = []  # list of tissues where OTU is found

        for j in range(1,38): # look in each data column- update based on input file; tally unique/shared
            if int(items[j]) > 0:
                if unique[Taxa] == "new":  # never had a >0 for this Taxa before
                   unique[Taxa] = header_items[j]
                elif headers[j] != unique[Taxa]:  # >0 in a different tissue
                    unique[Taxa] = "NO"
                if headers[j] not in shared[Taxa]:
                   shared[Taxa].append(header_items[j])

    lines = ()
    f.close()

    # now, output OTUs that are unique to one sample type
    uniqueOut = open ('uniqueTaxa_GROUPED_MEAN.tsv','w')
    uniqueOut.write("Taxa\tUniqueTissue\n")
    for thisTaxa in unique:
        if unique[thisTaxa] != "NO":  
            uniqueOut.write(thisTaxa + "\t" + unique[thisTaxa] + "\n")
    uniqueOut.close()

    # output OTUs that are shared among 2 or more samples(tissues)
    sharedOut = open('sharedTaxa_GROUPED_MEAN.tsv','w')
    sharedOut.write("OTU\tNumSharedTissues\tSharedTissues\n")
    for thisTaxa in shared:
        if len(shared[thisTaxa]) > 1: # at least 2 tissues
             sharedOut.write(thisTaxa + "\t" + str(len(shared[thisTaxa])) + "\t" + ','.join(shared[thisTaxa]) + "\n")
    sharedOut.close()


if __name__ == '__main__':
    main()
