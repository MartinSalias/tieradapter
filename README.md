# tieradapter
VFP 9 Application Framework 
-----------

(last updated on 2006)


**TierAdapter** was a layered app framework we wrote with Ruben Rovira in mid-2000s, in **VFP 9**.

It allows to build classic, monolithic apps (generating a single EXE file), but keeping layers logically segregated, as well as n-tier apps in an EXE for the desktop client plus n COM DLLs using Apartment Model Threading and deployable to COM+. It is able to scale pretty well and use either the old DBF format (which can be VERY fast and pretty secure if files are held in a single server) as well as any other database with its OleDB provider.

Disclaimer: I'm not supporting it anymore, but you are welcome to clone, fork and do whatever you want with it. :)


