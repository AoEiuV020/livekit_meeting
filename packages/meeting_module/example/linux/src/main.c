// main.c
#include <gtk/gtk.h>
#include <gtk/gtkx.h>
#include <gdk/gdkx.h>

static GtkWidget *socket = NULL;
static GPid child_pid = 0;

static void
launch_child_window(GtkWidget *widget, gpointer data)
{
    GError *error = NULL;
    char *argv[] = {"./child_window", NULL};
    g_spawn_async(NULL, argv, NULL,
                 G_SPAWN_SEARCH_PATH | G_SPAWN_DO_NOT_REAP_CHILD,
                 NULL, NULL, &child_pid, &error);
    
    if (error) {
        g_print("Error launching child: %s\n", error->message);
        g_error_free(error);
    }
}

static void
embed_child_window(GtkWidget *widget, gpointer data)
{
    if (!socket) {
        return;
    }
    Window socket_id = gtk_socket_get_id(GTK_SOCKET(socket));
    char socket_id_str[32];
    g_snprintf(socket_id_str, sizeof(socket_id_str), "%lu", socket_id);
    g_print("Trying to embed with socket ID: %s\n", socket_id_str);
    GError *error = NULL;
    char *argv[] = {"./child_window", socket_id_str, NULL};
    g_spawn_async(NULL, argv, NULL,
                 G_SPAWN_SEARCH_PATH | G_SPAWN_DO_NOT_REAP_CHILD,
                 NULL, NULL, &child_pid, &error);

    if (error) {
        g_print("Error embedding child: %s\n", error->message);
        g_error_free(error);
    }
}

static void
socket_plugged(GtkSocket *socket, gpointer data)
{
    g_print("Plug added to socket\n");
}

static void
socket_unplugged(GtkSocket *socket, gpointer data)
{
    g_print("Plug removed from socket\n");
}

static void
activate(GtkApplication *app, gpointer user_data)
{
    GtkWidget *window;
    GtkWidget *vbox;
    GtkWidget *hbox;
    GtkWidget *launch_button;
    GtkWidget *embed_button;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Main Window");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);

    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_container_add(GTK_CONTAINER(window), vbox);

    hbox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 5);
    gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 5);

    launch_button = gtk_button_new_with_label("Launch Child Window");
    g_signal_connect(launch_button, "clicked", G_CALLBACK(launch_child_window), NULL);
    gtk_box_pack_start(GTK_BOX(hbox), launch_button, TRUE, TRUE, 5);

    embed_button = gtk_button_new_with_label("Embed Child Window");
    g_signal_connect(embed_button, "clicked", G_CALLBACK(embed_child_window), NULL);
    gtk_box_pack_start(GTK_BOX(hbox), embed_button, TRUE, TRUE, 5);

    socket = gtk_socket_new();
    gtk_widget_set_size_request(socket, 200, 200);
    g_signal_connect(socket, "plug-added", G_CALLBACK(socket_plugged), NULL);
    g_signal_connect(socket, "plug-removed", G_CALLBACK(socket_unplugged), NULL);
    gtk_box_pack_start(GTK_BOX(vbox), socket, TRUE, TRUE, 0);

    gtk_widget_show_all(window);
}
int
main(int argc, char **argv)
{
    GtkApplication *app;
    int status;

    // 使用 G_APPLICATION_HANDLES_COMMAND_LINE 标志
    app = gtk_application_new("org.gtk.example.main",
                            G_APPLICATION_NON_UNIQUE |
                            G_APPLICATION_HANDLES_OPEN);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}