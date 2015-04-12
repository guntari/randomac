#!/usr/bin/awk -f

#####
##
##      DATE: 2015-04-11
##    AUTHOR: Emile Mercier
##   PURPOSE: Parse oui.txt into a associative array
##            with the key being the entire manufacturer string.
##            for use during compiling randomac.c
##
##     NOTE: after running this on oui.txt, it becomes obvious that the data is
##           not normalized.
##
##           For example, look at this output:
##              2wire>--001FB3 00217C 0022A4 002351 002456 00253C 002650 28162E 34EF44 383BC8 3CEA4F
##              2wire inc>------60C397 94C150
##              2wire inc.>-----001D5A
##              2wire, inc>-----000D72 001288 00183F 0019E4 001AC4
##              2wire, inc.>----001495 001B5B 001EC7 00D09E
##
##           sloppy :(
##
##
##    USAGE: parseOui.awk oui.txt

# take action only the lines matching "base 16" in oui.txt
/base 16/ {
    count+=1;
    mfgString=""

    # store the base 16 mac prefix in an array named MacPrefix
    MacPrefix[count] = sprintf("%s", $1);

    # store the entire manufacturer name in the variable mfgString
    # I did this in awk but sed or cut in shell is what i'd rather do.
    # "from here to end of line" in awk is pretty ugly
    for (i=4; i<=NF; ++i) {
        # if condition is so that mfgString doesn't have a preceeding space
        if ( i == 4)
            mfgString = sprintf("%s",$i);
        else
            mfgString = sprintf("%s %s", mfgString, sprintf("%s",$i) );
    }

    # Store the manufacturer string "mfgString" in a associative array "Manuf"
    # as the "primary key"
    # each mac prefix associated with the literal manufacturer string
    # is then stored, space delimited, in it.
    # The if condition is so that first mac prefix entry isn't preceeded by a space
    if ( Manuf[ tolower(mfgString) ] == "" )
        Manuf[ tolower(mfgString) ] = sprintf("%s", MacPrefix[count]);
    else
        Manuf[ tolower(mfgString) ] = sprintf("%s %s",Manuf[ tolower(mfgString) ],MacPrefix[count]);
}

END{
   for (i in Manuf)
       printf( "%s\t%s\n", i, Manuf[i] );
}

