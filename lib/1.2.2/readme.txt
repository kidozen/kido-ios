This build contains new features. To include it in your project:

1 - Add kz.client.a to your project ( remember to add headers in “Headers search path”). If you don’t know how to, please have a look at the following link. http://docs.kidozen.com/ios-sdk-1-2/#How-to-Include-the-KidoZen-SDK-for-iOS-in-an-Existing-Application

2 - In your application target, select: “Build Phases”, “Link Binary With Libraries” and add:
	* libc++.dylib
	* libicucore.dylib
	* Security.framework
	* CFNetwork.framework
	* CoreTelephony.framework
	* CoreLocation.framework
	* SystemConfiguration.framework

3 - In “Other linker Flags” add:
	* -all_load
	* -ObjC


If you want to have the full installation documentation, have a look at http://docs.kidozen.com/ios-sdk-1-2/

