var exec = require('cordova/exec');

/**
 * Saves data to the native side.
 *
 * @param {Object} options - The data to save. For example:
 *   { type: "fasting", value: 3600 }
 *   or { type: "calories", remainingCalories: 1200, calorieGoal: 2000, caloriesTaken: 800, caloriesBurned: 150 }
 * @param {Function} success - Callback for a successful call.
 * @param {Function} error - Callback for errors.
 */
exports.saveData = function(options, success, error) {
    exec(success, error, 'WidgetSettings', 'saveData', [options]);
};

/**
 * Retrieves data from the native side.
 *
 * @param {Object} options - Options specifying which data to retrieve. For example:
 *   { type: "fasting" }
 *   or { type: "calories" }
 * @param {Function} success - Callback for a successful call.
 * @param {Function} error - Callback for errors.
 */
exports.getData = function(options, success, error) {
    exec(success, error, 'WidgetSettings', 'getData', [options]);
};
