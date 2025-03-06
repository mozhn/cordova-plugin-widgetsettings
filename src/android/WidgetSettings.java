package com.askipo.patient;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;
import org.json.JSONObject;

public class WidgetSettings extends CordovaPlugin {
    private static final String PREFS_NAME = "com.askipo.patient";
    private static final String REMAINING_CALORIES = "remainingCalories";
    private static final String CALORIE_GOAL = "calorieGoal";
    private static final String CALORIES_TAKEN = "caloriesTaken";
    private static final String CALORIES_BURNED = "caloriesBurned";

    @Override
    public boolean execute(String action, org.json.JSONArray args, CallbackContext callbackContext) {
        if (action.equals("saveData")) {
            try {
                JSONObject data = args.getJSONObject(0);
                int remainingCalories = data.optInt("remainingCalories", 1620);
                int calorieGoal = data.optInt("calorieGoal", 250);
                int caloriesTaken = data.optInt("caloriesTaken", 40);
                int caloriesBurned = data.optInt("caloriesBurned", 150);

                saveCaloriesData(cordova.getContext(), remainingCalories, calorieGoal, caloriesTaken, caloriesBurned);
                callbackContext.success("Widget updated successfully!");
                return true;

            } catch (JSONException e) {
                callbackContext.error("Error parsing JSON");
                return false;
            }
        }
        return false;
    }

    private void saveCaloriesData(Context context, int remainingCalories, int goal, int taken, int burned) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putInt(REMAINING_CALORIES, remainingCalories);
        editor.putInt(CALORIE_GOAL, goal);
        editor.putInt(CALORIES_TAKEN, taken);
        editor.putInt(CALORIES_BURNED, burned);
        editor.apply();

        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        ComponentName componentName = new ComponentName(context, CalorieWidgetProvider.class);
        int[] widgetIds = appWidgetManager.getAppWidgetIds(componentName);
        for (int widgetId : widgetIds) {
            CalorieWidgetProvider.updateAppWidget(context, appWidgetManager, widgetId);
        }
    }
}
