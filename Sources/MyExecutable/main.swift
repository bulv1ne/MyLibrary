import Foundation
import MyLibrary

print("Hello world")

sayHelloFromMyLib(name: "Niels")

let dateFormatter = DateFormatter()
dateFormatter.locale = Locale(identifier: "UTC+2") // set locale to reliable US_POSIX
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
// let date = dateFormatter.date(from:isoDate)!

struct DataPoint {
    var timestamp: Date
    var Value: Float
}

var sema = DispatchSemaphore(value: 0)

let session = URLSession.shared
let urlString = "https://www.vattenfall.se/api/price/spot/pricearea/2021-06-08/2021-06-09/SN4"
let url = URL(string: urlString)!
var request = URLRequest(url: url)

var finalTimestamp: Date?

let task = session.dataTask(with: request) { (data, response, error) in
    if let error = error {
        print("Error: \(error)")
    } else if let data = data, let httpResponse = response as? HTTPURLResponse {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            // print(json)
            if let timestampString = json[0]["TimeStamp"] as? String, let timestamp = dateFormatter.date(from: timestampString), let value = json[0]["Value"] as? Float {
                print(timestampString)
                print(timestamp)
                print(value)
                finalTimestamp = timestamp
            } else {
                print("No value")
            }
        }
        // print("Data: \(dataString)")
        print("Status code \(httpResponse.statusCode)")
    } else {
        print("Don't know what this error is...")

    }
    sema.signal()
}

task.resume()

print("Waiting for semaphore")
sema.wait()
print("Semaphore done")
if let finalTimestamp = finalTimestamp {
    print("Final timestamp is \(finalTimestamp)")
} else {
    print("Final timestamp not set")
}
