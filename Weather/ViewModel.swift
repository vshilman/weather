import Foundation

class ViewModel {
    
    var weatherData: DataModel?
    
    var updateUI: (() -> Void)?

///TODO: no time to implement Constants, nut ideally would use that
    func fetchWeatherWithConsts(_ city: String) {
        let urlString = Constants.API.weatherURL(forCity: city)
        fetchWeatherData(from: urlString)
    }

    func fetchWeatherForLocationWithConsts(lat: Double, lon: Double) {
        let urlString = Constants.API.weatherURL(forLatitude: lat, longitude: lon)
        fetchWeatherData(from: urlString)
    }
    
    
    
    
    func fetchWeather(_ city: String) {
        let apiKey = "3a7174ed8c9a357d0fc166c2422679e2"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city),US&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let weather = try JSONDecoder().decode(DataModel.self, from: data)
                
                DispatchQueue.main.async {
                    self.weatherData = weather
                    self.updateUI?()
                }
                
            } catch let decodingError {
                print("Error decoding weather data: \(decodingError.localizedDescription)")
            }
            
        }.resume()
    }

    
    func fetchWeatherForLocation(lat: Double, lon: Double) {
            let apiKey = "3a7174ed8c9a357d0fc166c2422679e2"
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
            
            fetchWeatherData(from: urlString)
        }

        private func fetchWeatherData(from urlString: String) {
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching weather data: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let weather = try JSONDecoder().decode(DataModel.self, from: data)
                    DispatchQueue.main.async {
                        self.weatherData = weather
                        self.updateUI?()
                    }
                } catch let decodingError {
                    print("Error decoding weather data: \(decodingError.localizedDescription)")
                }
            }.resume()
        }
    
    
    func getTemperature() -> String {
        return "\(weatherData?.main.temp ?? 0.0) °C"
    }
    
    func getWeatherDescription() -> String {
        return weatherData?.weather.first?.description.capitalized ?? ""
    }
    
    func getHumidity() -> String {
        return "Humidity: \(weatherData?.main.humidity ?? 0)%"
    }
    
    func getIconURL() -> String {
        guard let icon = weatherData?.weather.first?.icon else { return "" }
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
}
