package lv.draugiem.cordova;

import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import draugiem.lv.api.AuthCallback;
import draugiem.lv.api.DraugiemAuth;
import draugiem.lv.api.User;

public class DraugiemApi extends CordovaPlugin
{
	public static final int ERROR_INIT_NOT_CALLED = 1000;
	public static final int ERROR_UNKNOWN = 1001;
	public static final int ERROR_JSON = 1002;
	public static final int ERROR_NO_APP = 1003;
	
	private DraugiemAuth mDraugiemAuth;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
	        try {
		        if (args.length() != 1) {
			        throw new IllegalArgumentException();
		        }

		        String apiKey;

		        try {
			        apiKey = args.getString(0);
		        } catch (JSONException e) {
			        throw new IllegalArgumentException(e);
		        }

		        this.init(apiKey);
	        } catch (IllegalArgumentException e) {
		        callbackContext.error("init requires a single argument: a 32-character string - apiKey");
	        }

			callbackContext.success();
	        return true;
        } else if (action.equals("login")) {
            this.login(callbackContext);
            return true;
        }
        
        return false;
    }

	@Override
	protected void pluginInitialize()
	{
		super.pluginInitialize();
		cordova.setActivityResultCallback(this);
	}

	private void init(final String apiKey) {
		mDraugiemAuth = new DraugiemAuth(apiKey, cordova.getActivity());
	}

	private void login(final CallbackContext callbackContext) {
		if (mDraugiemAuth == null) {
			callbackContext.error(ERROR_INIT_NOT_CALLED);
			return;
		}

		mDraugiemAuth.authorize(new AuthCallback() {
			@Override
			public void onLogin(User user, String apiKey) {
				try {
					final JSONObject jsonUser = new JSONObject();
					jsonUser.put("id", user.id);
					jsonUser.put("age", user.age);
					jsonUser.put("sex", user.sex);
					jsonUser.put("name", user.name + " " + user.surname);
					jsonUser.put("nick", user.nick);
					jsonUser.put("city", user.city);
					jsonUser.put("imageIcon", user.imageIcon);
					jsonUser.put("imageLarge", user.imageLarge);
					jsonUser.put("birthday", user.birthday);
				
					final JSONObject json = new JSONObject();
					json.put("apiKey", apiKey);
					json.put("user", jsonUser);
					
					callbackContext.success(json);
				} catch (JSONException e) {
					callbackContext.error(ERROR_JSON);
				}
			}
			
			@Override
			public void onError() {
				callbackContext.error(ERROR_UNKNOWN);
			}
			
			@Override
			public void onNoApp() {
				callbackContext.error(ERROR_NO_APP);
			}
		});
    }

	@Override
	public void onActivityResult(final int requestCode, final int resultCode, final Intent intent)
	{
		if (mDraugiemAuth != null && mDraugiemAuth.onActivityResult(requestCode, resultCode, intent)) {
			return;
		}

		super.onActivityResult(requestCode, resultCode, intent);
	}
}
