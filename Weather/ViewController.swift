import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var viewModel: ViewModel?
    let locationManager = CLLocationManager()

    let cityTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter US city"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
        
        let fetchButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Show Weather", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        let temperatureLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let weatherDescriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let humidityLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let weatherIconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Initialize the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        

        
        setupViews()
        setupConstraints()
        
        fetchButton.addTarget(self, action: #selector(fetchWeather), for: .touchUpInside)
        
        // Bind ViewModel to update UI
        viewModel?.updateUI = { [weak self] in
            self?.updateWeatherInfo()
        }
        
        checkLocationServices()
    }
    
    // Function to check if location services are enabled
    func checkLocationServices() {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                // Now we can check the location authorization status
                self.checkLocationAuthorization()
            } else {
                print("location problem...")
            }
        }
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            print("Location access denied.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location access restricted.")
        @unknown default:
            print("Unknown location authorization status.")
        }
    }
    
    @objc func fetchWeather() {
        if let city = cityTextField.text, !city.isEmpty {
            viewModel?.fetchWeather(city)
        }
    }
    
    
    func updateWeatherInfo() {
        temperatureLabel.text = viewModel?.getTemperature()
        weatherDescriptionLabel.text = viewModel?.getWeatherDescription()
        humidityLabel.text = viewModel?.getHumidity()
        
        if let iconURL = viewModel?.getIconURL() {
            loadImage(from: iconURL)
        }
    }
    
    // loading with caching
        private func loadImage(from urlString: String) {
            guard let url = URL(string: urlString) else { return }
            
            let cache = URLCache.shared
            let request = URLRequest(url: url)
            
            // Check if image is in cache
            if let cachedResponse = cache.cachedResponse(for: request) {
                self.weatherIconImageView.image = UIImage(data: cachedResponse.data)
                return
            }
            
            // If not cached, download the image
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response, error == nil else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Cache the image
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
                
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    
    private func setupViews() {
            view.addSubview(cityTextField)
            view.addSubview(fetchButton)
            view.addSubview(temperatureLabel)
            view.addSubview(weatherDescriptionLabel)
            view.addSubview(humidityLabel)
            view.addSubview(weatherIconImageView)
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                cityTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cityTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                cityTextField.widthAnchor.constraint(equalToConstant: 250),
                
                fetchButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 20),
                fetchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                temperatureLabel.topAnchor.constraint(equalTo: fetchButton.bottomAnchor, constant: 40),
                temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                weatherDescriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
                weatherDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                humidityLabel.topAnchor.constraint(equalTo: weatherDescriptionLabel.bottomAnchor, constant: 10),
                humidityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                weatherIconImageView.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 20),
                weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
                weatherIconImageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    
    func requestLocationAccess() {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.requestWhenInUseAuthorization()
            } else {
                print("Location services are not enabled.")
            }
        }
    }

    
    ///MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Fetch with location
            fetchWeatherForLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    /// TODO: error???
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Vadim, error 1")
        case .notDetermined:
            print("Vadim Error 2")
        @unknown default:
            print("Vadim Error 3")
        }
    }

    // Function to fetch weather based on latitude and longitude
    func fetchWeatherForLocation(latitude: Double, longitude: Double) {
        viewModel?.fetchWeatherForLocation(lat: latitude, lon: longitude)
    }
}
