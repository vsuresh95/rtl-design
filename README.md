# design_proj

Ensure that [Makefile](Makefile) is edited to include the correct path to your VCS_HOME/VERDI_HOME. If you are using any other compiler/simulator, please customize the Makefile accordingly.

## Compile and link and run:
```
cd [TEST FOLDER]
make
```

## Open waveform
```
cd [TEST FOLDER]
make debug
```
Opens in DVE by default; pass DUMP_FSDB=y to open in verdi

## Clean test work area
```
cd [TEST FOLDER]
make clean
```
