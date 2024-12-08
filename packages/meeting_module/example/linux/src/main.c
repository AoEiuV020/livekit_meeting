#include <gtk/gtk.h>
#include <stdlib.h>

static void
button_clicked(GtkWidget *widget, gpointer data)
{
    system("./child_window");
}

static void
activate(GtkApplication *app, gpointer user_data)
{
    GtkWidget *window;
    GtkWidget *button;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Main Window");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 200);

    button = gtk_button_new_with_label("Open Child Window");
    g_signal_connect(button, "clicked", G_CALLBACK(button_clicked), NULL);
    gtk_container_add(GTK_CONTAINER(window), button);

    gtk_widget_show_all(window);
}

int
main(int argc, char **argv)
{
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}