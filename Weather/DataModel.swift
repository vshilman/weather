import Foundation


struct Constants {
    
    struct API {
        static let apiKey = "YOUR_API_KEY" // Replace with your actual API key
        static let baseURL = "https://api.openweathermap.org/data/2.5/"
        
        static func weatherURL(forCity city: String) -> String {
            return "\(baseURL)weather?q=\(city)&appid=\(apiKey)&units=metric"
        }
        
        static func weatherURL(forLatitude latitude: Double, longitude: Double) -> String {
            return "\(baseURL)weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        }
    }
}


struct DataModel: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
    let icon: String
}
