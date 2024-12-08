// child.c
#include <gtk/gtk.h>
#include <gtk/gtkx.h>
#include <gdk/gdkx.h>

static void
activate(GtkApplication *app, gpointer user_data)
{
    GtkWidget *plug;
    GtkWidget *label;
    char **argv = (char **)user_data;

    if (argv && argv[1])
    {
        Window socket_id = strtoul(argv[1], NULL, 10);
        g_print("Trying to create plug with socket ID: %lu\n", socket_id);
        plug = gtk_plug_new(socket_id);
        if (gtk_plug_get_embedded(GTK_PLUG(plug)))
        {
            g_print("Plug successfully embedded into the socket.\n");
        }
        else
        {
            g_print("Failed to embed Plug into the socket.\n");
        }
    }
    else
    {
        plug = gtk_application_window_new(app);
        gtk_window_set_title(GTK_WINDOW(plug), "Child Window");
        gtk_window_set_default_size(GTK_WINDOW(plug), 200, 100);
    }

    label = gtk_label_new("Child Window Content");
    gtk_container_add(GTK_CONTAINER(plug), label);

    gtk_widget_show_all(plug);
}

int main(int argc, char **argv)
{
    g_print("Child window activated with argc: %d\n", argc);
    if (argc > 1)
    {
        g_print("Got socket ID parameter: %s\n", argv[1]);
    }
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.gtk.example.child", G_APPLICATION_NON_UNIQUE);
    // 直接传递 argv 到 activate 回调
    g_signal_connect(app, "activate", G_CALLBACK(activate), argv);
    status = g_application_run(G_APPLICATION(app), 0, argv);
    g_object_unref(app);

    return status;
}