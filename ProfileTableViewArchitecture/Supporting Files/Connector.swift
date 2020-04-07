//
//  Connector.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import Foundation
import Firebase

class Connector
{
    static var shared: Connector {
        struct Static {
            static let instance = Connector()
        }

        return Static.instance
    }
    
    private let ref = Database.database().reference()
    
    // onSuccess is called every time we get data pushed from DB
    func observeData(onSuccess: @escaping (Profile) -> Void)
    {
        self.ref.observe(.value) { (snapshot) in
            // get the dictionary and turn it back into JSON then use JSONDecoder
            // this is dumb but I don't want to write a dictionary -> Profile fn rn
            DispatchQueue.global(qos: .userInitiated).async {
                if let profileData = snapshot.value as? [String: Any] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: profileData, options: .prettyPrinted)
                        let profile = try JSONDecoder().decode(Profile.self, from: data)
                        
                        DispatchQueue.main.async {
                            onSuccess(profile)
                        }
                    }
                    catch {
                        print("Error parsing profile data: \(error)")
                    }
                }
            }
        }
    }
}
