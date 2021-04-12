# URLShortener

URLShortener leverages tinyurl to shorten provided URLs. They are also cached so future requests will not make a network request.

## Running the application
There are a few main ways to run this application.
    1. Double click on the Package.swift file to open up Xcode, running normally will start the interactive mode. To run with different options
        Edit the Scheme and set the arguments passed on launch.
    2. From terminal in the application directory use: `swift run URLShortener` to enter interactive mode. For one offs use `swift run URLShortener -u http://url.com`
    3. Install the application in your computers system path.
        `swift build --configuration release`
        `cp -f .build/release/URLShortener /usr/local/bin/urlshortener`
        
To see the help instructions run the app with the `-h` flag. (`swift run URLShortener -h`)
To see a list of the top cached URLs use the `-t` flag with an optional limit `Int` value. The default is 3 (`swift run URLShortener -t 5`)

## Testing
For a look at code coverage it is best to run the tests in Xcode by opening the Package.swift and enabling Code Coverage under test -> Options. It is also possible to
generage JSON or lcov which requires installing additional tools from the terminal.

To run tests from the terminal without code coverage run `swift test` from the packages directory. 
To run inside Xcode just hit `Command + U`.

There are pretty much complete tests for FileManagerExtensions.swift, TinyURL.swift, URLCache.swift.

With this being the first ever console application I have written in swift I got stuck a bit writing tests for the Console portion of this app.


*NOTE:* For a production version of a console tool I where I could use third party software I would leverage: https://github.com/apple/swift-argument-parser,
which would allow the code to be much more extendable as well as testable.
