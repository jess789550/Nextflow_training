// class Metadata extends HashMap {
//     def hi() {
//         return "Hello, workshop participants!"
//     }
// }

import groovy.json.JsonSlurper

class Metadata extends HashMap {
    Metadata(String location) {
        this.location = location
    }
    
    // print hello
    def hi() {
        return this.location ? "Hello, from ${this.location}!" : "Hello, workshop participants!"
    }
    
    // // grab the adapter prefix
    // def getAdapterStart() {
    //     this.adapter?.substring(0, 3)
    // }

    // does not change the hash
        def getAdapterStart() {
        this.adapter?.substring(0, 5)
    }
    
    // get info from public API
    def getSampleName() {
        def get = new URL('https://postman-echo.com/get?sampleName=Fido').openConnection()
        def getRC = get.getResponseCode();
        if (getRC.equals(200)) {
            JsonSlurper jsonSlurper = new JsonSlurper()
            def json = jsonSlurper.parseText(get.getInputStream().getText())
            return json.args.sampleName
        }
    }
}
