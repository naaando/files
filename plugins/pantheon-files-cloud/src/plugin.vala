/***
    Copyright (c) 2018 elementary LLC <https://elementary.io>

    Pantheon Files is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.

    Pantheon Files is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>.

    Author(s):  Fernando da Silva Sousa <wild.nando@gmail.com>
***/

public class Marlin.Plugins.Cloud.Plugin : Marlin.Plugins.Base {
    Manager cloud_manager;

    public Plugin () {
        cloud_manager = new Manager ();
    }

    /**
     * Connect signals to reload sidebar whenever a provider or account change
     *
     * @param a instance of Marlin.AbstractSidebar
     */
    public override void sidebar_loaded (Gtk.Widget widget) {
        var sidebar = widget as Marlin.AbstractSidebar;
        cloud_manager.providers_changed.connect (() => sidebar.request_update ());
        cloud_manager.accounts_changed.connect (() => sidebar.request_update ());
    }

    /**
     * Plugin hook that triggers when sidebar receives a update request on
     * Marlin's code
     *
     * @param a instance of Marlin.AbstractSidebar
     */
    public override void update_sidebar (Gtk.Widget widget) {
        var sidebar = widget as Marlin.AbstractSidebar;
        foreach (CloudProviders.Account account in cloud_manager.get_accounts ()) {
            //  Fix menu loading with wrong order by forcing dbus to cache menu_model
            account.menu_model.get_n_items ();

            var reference = sidebar.add_plugin_item (adapt_plugin_item (account), Marlin.PlaceType.NETWORK_CATEGORY);
            account.notify.connect (() => {
                sidebar.update_plugin_item (adapt_plugin_item (account), reference);
            });
        }
    }

    public Marlin.PluginItem adapt_plugin_item (CloudProviders.Account account) {
        var item = new Marlin.PluginItem ();
        item.name = account.name;
        item.tooltip = account.path;
        item.uri = account.path;
        item.icon = account.icon;
        item.show_spinner = account.get_status () == CloudProviders.AccountStatus.SYNCING;
        item.menu_model = account.menu_model;
        item.action_icon = get_icon (account.get_status ());
        return item;
    }

    /**
     * Get icon for current account status
     *
     * @param a status {@link CloudProviders.AccountStatus} of a {@link CloudProviders.Account}
     *
     * @return a error icon if status is error else returns null
     */
    Icon? get_icon (CloudProviders.AccountStatus status) {
        return status == CloudProviders.AccountStatus.ERROR ?
                         new ThemedIcon.with_default_fallbacks ("dialog-error-symbolic") :
                         null;
    }
}

public Marlin.Plugins.Base module_init () {
    return new Marlin.Plugins.Cloud.Plugin ();
}
