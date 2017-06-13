# Install

```sh
cordova plugin add https://github.com/jonas-m-/cordova-plugin-draugiem-sdk.git --save --APP_ID=<insertYourAppIdHere>
```
* For info, how to get your APP_ID, see here: https://github.com/Draugiem/draugiem-ios-sdk

# Usage

```javascript
// String API key, consisting of exactly 32 characters
var apiKey = "f284ccdf7936b927f4c65d67e5c2fd2b";

DraugiemApi.init(apiKey);

function onLoggedIn(response) {
    // Yay! Login was successful
    console.log(response.apiKey); // string, access token
    console.log(response.user); // object, user data
}

function onLoginFailed(error) {
    console.error(error);
}

DraugiemApi.login(onLoggedIn, onLoginFailed);
```
* For info, how to get your API key, see here: https://github.com/Draugiem/draugiem-ios-sdk

# Success response structure

Property name | Variable type | Description | Example
--------------|---------------|-------------|--------
apiKey | string | Access token for accessing data of current user | FIXME
user | object | Data of current user | -
user.id | int | Unique identifier of the user | FIXME
user.age | int | Age in years | `24`
user.sex | string | User's gender. Either `male` or `female` | `male`
user.name | string | User's full name | Oskars Cerins
user.nick | string or null | Nickname of the user | oskars52
user.city | string | name of the user's city | Riga
