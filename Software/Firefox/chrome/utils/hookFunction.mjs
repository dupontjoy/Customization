/**
 * Add hooks to a function to execute before and after it. The function to modify is functionContext[functionName]. Call only once per function - modification is not supported.
 * 
 * Other addons wishing to access the original function may do so using the .originalFunction member of the replacement function. This member can also be set if required, to insert a new function replacement into the chain rather than appending.
 * 
 * @param functionContext The object on which the function is a property
 * @param functionName The name of the property containing the function (on functionContext)
 * @param onBeforeFunction A function to be called before the hooked function is executed. It will be passed the same parameters as the hooked function. It's return value will be passed on to onAfterFunction
 * @param onAfterFunction A function to be called after the hooked function is executed. The parameters passed to it are: onBeforeFunction return value, arguments object from original hooked function, return value from original hooked function. It's return value will be returned in place of that of the original function.
 * @returns A function which can be called to safely un-hook the hook
 */
export function hookFunction(functionContext, functionName, onBeforeFunction, onAfterFunction) {
    let originalFunction = functionContext[functionName];

    if (!originalFunction) {
        throw new Error("Could not find function " + functionName);
    }

    let replacementFunction = function() {
        let onBeforeResult = null;
        if (onBeforeFunction) {
            onBeforeResult = onBeforeFunction.apply(this, arguments);
        }
        let originalResult = replacementFunction.originalFunction.apply(this, arguments);
        if (onAfterFunction) {
            return onAfterFunction.call(this, onBeforeResult, arguments, originalResult);
        } else {
            return originalResult;
        }
    }
    replacementFunction.originalFunction = originalFunction;
    functionContext[functionName] = replacementFunction;

    return function () {
        // Not safe to simply assign originalFunction back again, as something else might have chained onto this function, which would then break the chain
        // Unassigning these variables prevent any effects of the hook, though the function itself remains in place.
        onBeforeFunction = null;
        onAfterFunction = null;
    };
}