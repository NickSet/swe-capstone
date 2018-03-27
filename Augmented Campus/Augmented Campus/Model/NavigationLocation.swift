
public struct NavigationLocation: Codable {
	var latitude: Double
	var longitude: Double
	var name: String
	var fScore: Double?
}

extension NavigationLocation: CustomStringConvertible {
	public var description: String {
		// Returns the variable name of NavigationLocation if NavigationLocation itself is used without calling functions or variables.
		return "\(name)"
	}
}

extension NavigationLocation: Hashable {
	public var hashValue: Int {
		let string = "\(latitude)\(longitude)\(name)"
		return string.hashValue
	}
		
}

public func == (lhs: NavigationLocation, rhs: NavigationLocation) -> Bool {
		
		guard lhs.latitude == rhs.latitude else {
			return false
		}
		
		guard lhs.longitude == rhs.longitude else {
			return false
		}
		
		guard lhs.name == rhs.name else {
			return false
		}
			
		return true
	}
