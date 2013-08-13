#Kidozen SDK for iOS Devices

The SDK has a dependency with SocketRocket if you clone the sources you must download it and add it as a library or a sub-project

In order to use the iOS SDK binaries in your android application you must:

- Download the lib folder. This folder contains all the headers and static libs files
- In Xcode, open Project Navigator and select your project file.
- Import the following libraryies and frameworks:
  - libicucore.dylib
  - security.framework
  - cfnetwork.framework
- On the right panel, click the Build Phases
  - Search Header Search Paths and include the path where the KidoZen headers files are
  - Search Library Search Paths and include the path where the KidoZen static library file is
  - Search Other Linker Flags and include -allLoad and -ObjC

##Getting started with the code
One instance of the Application object has one or many instances of each of the services that you can find in the Kidozen platform (Storage, Queue, etc.) 
The SDK API is callback based on all its interfaces to avoid UI block. The callback signature is the same for all the methods: 

- `urlResponse` is the underlying NSHTTPURLResponse object.
- `Response` the response body of the call. It could be an string with the description of the operation such as "Created" or "Internal server error" or a NSDictionary Object with the results of one operation
- `Error` the NSError object is there was one

Initialize the Application: During initialization the SDK pulls the application configuration from the cloud services for the specified platform

  	KZApplication * app = [[KZApplication alloc] initWithTennantMarketPlace:TENANT 
                                                            applicationName:APP 
                                                                andCallback:^(KZResponse * r) {
			...
		}];

Then you must Authenticate against kidozen. To do that you must provide the identity provider that you will use the username and the password. The SDK hides all the calls needed to authenticate the user against the selected identity provider and to create a security context to execute all the services call.

		[app authenticateUser:USER withProvider:PROVIDER andPassword:PASS completion:^(id r) {
		...
		}];

Once the user is authenticated you can start using all the services:

		tasks = [app StorageWithName:@"tasks"];
		[tasks create:t completion:^(KZResponse * kr) {
		...
		}];
		...
		queue = [app QueueWithName:@"messages"];
		[queue enqueue completion:^(KZResponse * kr) {
		...
		}];


#License 

Copyright (c) 2013 KidoZen, inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
