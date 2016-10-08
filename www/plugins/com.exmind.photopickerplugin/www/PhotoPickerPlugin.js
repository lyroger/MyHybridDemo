cordova.define("com.exmind.photopickerplugin.PhotoPickerPlugin", function(require, exports, module) {
               
       var argscheck = require('cordova/argscheck');
       var exec = require('cordova/exec');
       
       var PhotoPickerPlugin = function() {
       
       };
            
       // 获取系统相册图片
       PhotoPickerPlugin.prototype.getPictures = function(success, fail, maxCount) {
           exec(success, fail, "PhotoPickerPlugin", "getPictures", [maxCount]);
       };
    
       // 删除图片
       PhotoPickerPlugin.prototype.deleteFile = function(success, fail, filePaths) {
           exec(success, fail, "PhotoPickerPlugin", "deleteFile", filePaths);
       };
       
       var me = new PhotoPickerPlugin();
       module.exports = me;
});
