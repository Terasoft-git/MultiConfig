MULTI=/m
OUT=.\Out	
PROJ=MultiCfgIface

all: clean 
   make dll32 
   make dll64 
   dir $(OUT)
   gpg --output $(OUT)\SHA256SUMS.asc --clear-sign $(OUT)\SHA256SUMS

dll32: 
   msbuild "$(PROJ).dproj" $(MULTI) /p:Platform="Win32" /p:Config=Release;DCC_ExeOutput="$(OUT)" /t:Build
   cd $(OUT)
   upx -9 $(PROJ).dll
   upx -t $(PROJ).dll
   ren $(PROJ).dll $(PROJ)32.dll
   sha256sum $(PROJ)32.dll >> SHA256SUMS

dll64:
   msbuild "$(PROJ).dproj" $(MULTI) /p:Platform="Win64" /p:Config=Release;DCC_ExeOutput="$(OUT)" /t:Build
   cd $(OUT)
   upx -9 $(PROJ).dll
   upx -t $(PROJ).dll
   ren $(PROJ).dll $(PROJ)64.dll
   sha256sum $(PROJ)64.dll >> SHA256SUMS


clean:
   -del $(OUT)\SHA256SUMS.asc	
   -del $(OUT)\SHA256SUMS
   -del $(OUT)\$(PROJ).dll
   -del $(OUT)\$(PROJ)32.dll
   -del $(OUT)\$(PROJ)64.dll
   msbuild "$(PROJ).dproj" $(MULTI) /p:Platform="Win32" /p:Config=Release;DCC_ExeOutput="$(OUT)" /t:Clean
   msbuild "$(PROJ).dproj" $(MULTI) /p:Platform="Win64" /p:Config=Release;DCC_ExeOutput="$(OUT)" /t:Clean
	