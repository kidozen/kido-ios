This build contains new features. To include it in your project:

1 - Add kz.client.a to your project ( remember to add headers in “Headers search path”)
2 - In your application target, select: “Build Phases”, “Link Binary With Libraries” and add:
	* libc++.dylib
	* libicucore.dylib
3 - In “Other linker Flags” add:
	* -all_load
	* -ObjC
