/**
 * $Id: editor_plugin_src.js,v 1.1.1.1 2008/09/09 19:44:51 sp208304 Exp $
 *
 * @author Moxiecode
 * @copyright Copyright � 2004-2006, Moxiecode Systems AB, All rights reserved.
 */

/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('nonbreaking');

var TinyMCE_NonBreakingPlugin = {
	getInfo : function() {
		return {
			longname : 'Nonbreaking space',
			author : 'Moxiecode Systems AB',
			authorurl : 'http://tinymce.moxiecode.com',
			infourl : 'http://tinymce.moxiecode.com/tinymce/docs/plugin_nonbreaking.html',
			version : tinyMCE.majorVersion + "." + tinyMCE.minorVersion
		};
	},

	getControlHTML : function(cn) {
		switch (cn) {
			case "nonbreaking":
				return tinyMCE.getButtonHTML(cn, 'lang_nonbreaking_desc', '{$pluginurl}/images/nonbreaking.gif', 'mceNonBreaking', false);
		}

		return "";
	},


	execCommand : function(editor_id, element, command, user_interface, value) {
		var inst = tinyMCE.getInstanceById(editor_id), h;

		switch (command) {
			case "mceNonBreaking":
				h = (inst.visualChars && inst.visualChars.state) ? '<span class="mceItemHiddenVisualChar">&middot;</span>' : '&nbsp;';
				tinyMCE.execInstanceCommand(editor_id, 'mceInsertContent', false, h);
				return true;
		}

		return false;
	},

	handleEvent : function(e) {
		var inst, h;

		if (!tinyMCE.isOpera && e.type == 'keydown' && e.keyCode == 9 && tinyMCE.getParam('nonbreaking_force_tab', false)) {
			inst = tinyMCE.selectedInstance;

			h = (inst.visualChars && inst.visualChars.state) ? '<span class="mceItemHiddenVisualChar">&middot;&middot;&middot;</span>' : '&nbsp;&nbsp;&nbsp;';
			tinyMCE.execInstanceCommand(inst.editorId, 'mceInsertContent', false, h);

			tinyMCE.cancelEvent(e);
			return false;
		}

		return true;
	}
};

tinyMCE.addPlugin("nonbreaking", TinyMCE_NonBreakingPlugin);
