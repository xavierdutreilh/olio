/**
 * $Id: editor_plugin_src.js,v 1.1.1.1 2008/09/09 19:44:59 sp208304 Exp $
 *
 * @author Moxiecode
 * @copyright Copyright � 2004-2006, Moxiecode Systems AB, All rights reserved.
 */

/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('advlink');

var TinyMCE_AdvancedLinkPlugin = {
	getInfo : function() {
		return {
			longname : 'Advanced link',
			author : 'Moxiecode Systems AB',
			authorurl : 'http://tinymce.moxiecode.com',
			infourl : 'http://tinymce.moxiecode.com/tinymce/docs/plugin_advlink.html',
			version : tinyMCE.majorVersion + "." + tinyMCE.minorVersion
		};
	},

	initInstance : function(inst) {
		inst.addShortcut('ctrl', 'k', 'lang_advlink_desc', 'mceAdvLink');
	},

	getControlHTML : function(cn) {
		switch (cn) {
			case "link":
				return tinyMCE.getButtonHTML(cn, 'lang_link_desc', '{$themeurl}/images/link.gif', 'mceAdvLink');
		}

		return "";
	},

	execCommand : function(editor_id, element, command, user_interface, value) {
		switch (command) {
			case "mceAdvLink":
				var anySelection = false;
				var inst = tinyMCE.getInstanceById(editor_id);
				var focusElm = inst.getFocusElement();
				var selectedText = inst.selection.getSelectedText();

				if (tinyMCE.selectedElement)
					anySelection = (tinyMCE.selectedElement.nodeName.toLowerCase() == "img") || (selectedText && selectedText.length > 0);

				if (anySelection || (focusElm != null && focusElm.nodeName == "A")) {
					var template = new Array();

					template['file']   = '../../plugins/advlink/link.htm';
					template['width']  = 480;
					template['height'] = 400;

					// Language specific width and height addons
					template['width']  += tinyMCE.getLang('lang_advlink_delta_width', 0);
					template['height'] += tinyMCE.getLang('lang_advlink_delta_height', 0);

					tinyMCE.openWindow(template, {editor_id : editor_id, inline : "yes"});
				}

				return true;
		}

		return false;
	},

	handleNodeChange : function(editor_id, node, undo_index, undo_levels, visual_aid, any_selection) {
		if (node == null)
			return;

		do {
			if (node.nodeName == "A" && tinyMCE.getAttrib(node, 'href') != "") {
				tinyMCE.switchClass(editor_id + '_advlink', 'mceButtonSelected');
				return true;
			}
		} while ((node = node.parentNode));

		if (any_selection) {
			tinyMCE.switchClass(editor_id + '_advlink', 'mceButtonNormal');
			return true;
		}

		tinyMCE.switchClass(editor_id + '_advlink', 'mceButtonDisabled');

		return true;
	}
};

tinyMCE.addPlugin("advlink", TinyMCE_AdvancedLinkPlugin);
