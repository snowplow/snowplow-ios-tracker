//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.

import Foundation

extension String {
    func toBase64(urlSafe: Bool = true) -> String {
        var encoded = Data(self.utf8).base64EncodedString()
        if urlSafe {
            // We need URL safe with no padding. Since there is no built-in way to do this, we transform
            // the encoded payload to make it URL safe by replacing chars that are different in the URL-safe
            // alphabet. Namely, 62 is - instead of +, and 63 _ instead of /.
            // See: https://tools.ietf.org/html/rfc4648#section-5
            encoded = encoded
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
            
            // There is also no padding since the length is implicitly known.
            encoded = encoded.trimmingCharacters(in: CharacterSet(charactersIn: "="))
        }
        return encoded
    }
}
