package me.mazlum.widgetsettings;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;
import org.json.JSONArray;
import org.json.JSONObject;
import java.lang.reflect.Method;

public class WidgetSettings extends CordovaPlugin {
    private static final String PREFS_NAME = "com.askipo.patient";
    
    // Kalori Widget Keys
    private static final String REMAINING_CALORIES = "remainingCalories";
    private static final String CALORIE_GOAL = "calorieGoal";
    private static final String CALORIES_TAKEN = "caloriesTaken";
    private static final String CALORIES_BURNED = "caloriesBurned";
    
    // Su Widget Keys
    private static final String WATER_CONSUMED = "waterConsumed";
    private static final String TOTAL_WATER_GOAL = "totalWaterGoal";
    private static final String WATER_INCREMENT = "waterIncrement";

    private static final String FASTING_START_TIME = "fastingStartDate";
    private static final String FASTING_END_TIME = "fastingEndDate";
    
    private static final String EVENT_TYPE = "eventType";

    private static final String MEAL_SCHEDULE = "mealSchedule";

    @Override
    public boolean execute(String action, org.json.JSONArray args, CallbackContext callbackContext) {
        if (action.equals("saveData")) {
            try {
                JSONObject data = args.getJSONObject(0);
                String type = data.optString("type");

                if (type.equals("calories")) {
                    int remainingCalories = data.optInt("remainingCalories", 0);
                    int calorieGoal = data.optInt("calorieGoal", 0);
                    int caloriesTaken = data.optInt("caloriesTaken", 0);
                    int caloriesBurned = data.optInt("caloriesBurned", 0);

                    saveCaloriesData(cordova.getContext(), remainingCalories, calorieGoal, caloriesTaken, caloriesBurned);
                    callbackContext.success("Calories Widget updated successfully!");
                    return true;

                } else if (type.equals("water")) {
                    int waterConsumed = data.optInt("waterConsumed", 0);
                    int totalWaterGoal = data.optInt("totalWaterGoal", 0);
                    int waterIncrement = data.optInt("waterIncrement", 0);

                    saveWaterData(cordova.getContext(), waterConsumed, totalWaterGoal, waterIncrement);
                    callbackContext.success("Water Widget updated successfully!");
                    return true;
                } else if (type.equals("fasting")) {
                    String fastingStartTime = data.optString("fastingStartDate", "");
                    String fastingEndTime = data.optString("fastingEndDate", "");

                    saveFastingData(cordova.getContext(), fastingStartTime, fastingEndTime);
                    callbackContext.success("Fasting Widget updated successfully!");
                    return true;

                } else if (type.equals("period")) {
                    String eventType = data.optString("eventType", "");

                    savePeriodData(cordova.getContext(), eventType);
                    callbackContext.success("Period Widget updated successfully!");
                    return true;
                } else if (type.equals("meal")) {
                    JSONArray meals = data.optJSONArray("meals");
                    if (meals != null) {
                        saveMealData(cordova.getContext(), meals);
                        callbackContext.success("Meal Widget updated successfully!");
                        return true;
                    } else {
                        callbackContext.error("Invalid meal data");
                        return false;
                    }
                } else {
                    callbackContext.error("Invalid widget type");
                    return false;
                }

            } catch (JSONException e) {
                callbackContext.error("Error parsing JSON");
                return false;
            }
        }
        return false;
    }

    private void savePeriodData(Context context, String eventType) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putString(EVENT_TYPE, eventType);
        editor.apply();

        updateWidget(context, "com.askipo.patient.PeriodWidgetProvider");
    }

    private void saveMealData(Context context, JSONArray meals) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putString(MEAL_SCHEDULE, meals.toString());
        editor.apply();
        updateWidget(context, "com.askipo.patient.MealWidgetProvider");
    }

    private void saveCaloriesData(Context context, int remainingCalories, int goal, int taken, int burned) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putInt(REMAINING_CALORIES, remainingCalories);
        editor.putInt(CALORIE_GOAL, goal);
        editor.putInt(CALORIES_TAKEN, taken);
        editor.putInt(CALORIES_BURNED, burned);
        editor.apply();

        updateWidget(context, "com.askipo.patient.CalorieWidgetProvider");
    }

    private void saveWaterData(Context context, int waterConsumed, int totalWaterGoal, int waterIncrement) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putInt(WATER_CONSUMED, waterConsumed);
        editor.putInt(TOTAL_WATER_GOAL, totalWaterGoal);
        editor.putInt(WATER_INCREMENT, waterIncrement);
        editor.apply();

        updateWidget(context, "com.askipo.patient.WaterWidgetProvider");
    }

    private void saveFastingData(Context context, String fastingStartTime, String fastingEndTime) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putString(FASTING_START_TIME, fastingStartTime);
        editor.putString(FASTING_END_TIME, fastingEndTime);
        editor.apply();

        updateWidget(context, "com.askipo.patient.FastingWidgetProvider");
    }

    private void updateWidget(Context context, String widgetProviderClassName) {
        try {
            Class<?> widgetProviderClass = Class.forName(widgetProviderClassName);
            Method updateMethod = widgetProviderClass.getDeclaredMethod("updateAppWidget", Context.class, AppWidgetManager.class, int.class);

            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName componentName = new ComponentName(context, widgetProviderClass);
            int[] widgetIds = appWidgetManager.getAppWidgetIds(componentName);

            for (int widgetId : widgetIds) {
                updateMethod.invoke(null, context, appWidgetManager, widgetId);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
