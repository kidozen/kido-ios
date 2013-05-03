#Kidozen SDK for iOS Devices

In order to use the iOS SDK in your android application

- Download the lib folder. This folder contains all the headers and static libs files
- In Xcode, open Project Navigator and select your project file.
- On the right panel, click the Build Phases
- Search Header Search Paths and include the path where the KidoZen headers files are
- Search Library Search Paths and include the path where the KidoZen static library file is
- Search Other Linker Flags and include -allLoad and -ObjC

You can also download the source code and import it in XCode

