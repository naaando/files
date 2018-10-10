/***
    Copyright (c) 2015-2018 elementary LLC <https://elementary.io>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation, Inc.,.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program. If not, see <http://www.gnu.org/licenses/>.

    Authors : Lucas Baudin <xapantu@gmail.com>
              Jeremy Wootten <jeremy@elementaryos.org>
***/

namespace Marlin {

    public delegate void PluginCallbackFunc (Gtk.Widget widget);
    public enum PlaceType {
        BUILT_IN,
        MOUNTED_VOLUME,
        BOOKMARK,
        BOOKMARKS_CATEGORY,
        PERSONAL_CATEGORY,
        STORAGE_CATEGORY,
        NETWORK_CATEGORY,
        PLUGIN_ITEM
    }

    public abstract class AbstractSidebar : Gtk.ScrolledWindow {
        public signal void request_update ();

        public enum Column {
            NAME,
            URI,
            DRIVE,
            VOLUME,
            MOUNT,
            ROW_TYPE,
            ICON,
            INDEX,
            CAN_EJECT,
            NO_EJECT,
            BOOKMARK,
            IS_CATEGORY,
            NOT_CATEGORY,
            TOOLTIP,
            ACTION_ICON,
            SHOW_SPINNER,
            SHOW_EJECT,
            SPINNER_PULSE,
            FREE_SPACE,
            DISK_SIZE,
            PLUGIN_CALLBACK,
            MENU_MODEL,
            COUNT
        }

        protected Gtk.TreeStore store;
        protected Gtk.TreeRowReference network_category_reference;
        protected Gtk.Box content_box;

        protected void init () {
            store = new Gtk.TreeStore (((int)Column.COUNT),
                                        typeof (string),            /* name */
                                        typeof (string),            /* uri */
                                        typeof (Drive),
                                        typeof (Volume),
                                        typeof (Mount),
                                        typeof (int),               /* row type*/
                                        typeof (Icon),              /* Primary icon */
                                        typeof (uint),              /* index*/
                                        typeof (bool),              /* can eject */
                                        typeof (bool),              /* cannot eject */
                                        typeof (bool),              /* is bookmark */
                                        typeof (bool),              /* is category */
                                        typeof (bool),              /* is not category */
                                        typeof (string),            /* tool tip */
                                        typeof (Icon),              /* Action icon (e.g. eject button) */
                                        typeof (bool),              /* Show spinner (not eject button) */
                                        typeof (bool),              /* Show eject button (not spinner) */
                                        typeof (uint),              /* Spinner pulse */
                                        typeof (uint64),            /* Free space */
                                        typeof (uint64),            /* For disks, total size */
                                        typeof (Marlin.PluginCallbackFunc),
                                        typeof (MenuModel)
                                        );

            content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.add (content_box);
            content_box.show_all ();
        }

        public void add_extra_network_item (string text, string tooltip, Icon? icon, Marlin.PluginCallbackFunc? cb) {
            add_extra_item (network_category_reference, text, tooltip, icon, cb);
        }

        public void add_plugin_item (string text, string tooltip, Icon? icon, Marlin.PluginCallbackFunc? cb, MenuModel? menu = null, Icon? action_icon = null) {
            add_extra_item (network_category_reference, text, tooltip, icon, cb, menu, action_icon);
        }

        public void add_extra_item (Gtk.TreeRowReference category, string text, string tooltip, Icon? icon,
                                    Marlin.PluginCallbackFunc? cb, MenuModel? menu = null, Icon? action_icon = null) {
            Gtk.TreeIter iter;
            store.get_iter (out iter, category.get_path ());
            iter = add_place (PlaceType.PLUGIN_ITEM,
                             iter,
                             text,
                             icon,
                             null,
                             null,
                             null,
                             null,
                             0,
                             tooltip,
                             action_icon);
            if (cb != null) {
                store.@set (iter, Column.PLUGIN_CALLBACK, cb);
            }

            if (menu != null) {
                store.@set (iter, Column.MENU_MODEL, menu);
            }
        }

       protected abstract Gtk.TreeIter add_place (Marlin.PlaceType place_type,
                                                  Gtk.TreeIter? parent,
                                                  string name,
                                                  Icon? icon,
                                                  string? uri,
                                                  Drive? drive,
                                                  Volume? volume,
                                                  Mount? mount,
                                                  uint index,
                                                  string? tooltip = null,
                                                  Icon? action_icon = null) ;
    }

    public class PluginItem : Object {
        public const PlaceType place_type = PlaceType.PLUGIN_ITEM;
        public string name { get;set; }
        public string? uri { get;set; }
        public Drive? drive { get;set; }
        public Volume? volume { get;set; }
        public Mount? mount { get;set; }
        public Icon? icon { get;set; }
        public uint index { get;set; }
        public bool can_eject { get;set; }
        public string? tooltip { get;set; }
        public Icon? action_icon { get; set; }
        public bool show_spinner { get;set; default = false; }
        public uint64 free_space { get;set; default = 0; }
        public uint64 disk_size { get;set; default = 0; }
        public MenuModel? menu_model { get;set; }
        public PluginCallbackFunc? callback { get;set; }

        public bool is_bookmark () {
            return place_type == Marlin.PlaceType.BOOKMARK;
        }

        public bool is_category () {
            return (place_type == Marlin.PlaceType.BOOKMARKS_CATEGORY) ||
                   (place_type == Marlin.PlaceType.PERSONAL_CATEGORY)  ||
                   (place_type == Marlin.PlaceType.STORAGE_CATEGORY)   ||
                   (place_type == Marlin.PlaceType.NETWORK_CATEGORY);
        }
    }
}
