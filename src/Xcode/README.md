# Xcode files for wya*

## Installing
If you are running this project for the first time, first install <a href="https://guides.cocoapods.org/using/getting-started.html" target="_blank">CocoaPods</a>
 
then run the following command in **this** directory
    
    $ pod install

This will resolve all the dependencies for the project. It generates a `cs130_project.xcworkspace` file. You must now use this for this project from now on instead of `cs130_project.xcodeproj`.

## Running with Ngrok

To test the app with the server, you need [ngrok](https://ngrok.com/download). After installing, run

    $ ngrok http 5000

This will forward whatever new IP ngrok gives you to http://localhost:5000. For example, if ngrok gives us http://86dc0c49.ngrok.io, our endpoints will be exposed at http://86dc0c49.ngrok.io/<endpoint>. So any requests made inside the client, should use this format

### Monitoring Incoming Requests

Open http://127.0.0.1:4040 to monitor incoming requests while testing. 
