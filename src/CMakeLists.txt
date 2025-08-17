set(singlewindow_SOURCES singlewindow.cpp kakoune_client.h kakoune_server.h)
qt_add_resources(singlewindow_QRC resources.qrc)

set(splitwindow_SOURCES splitwindow.cpp kakoune_client.h kakoune_server.h kakoune_alive_client_counter.h)
qt_add_resources(splitwindow_QRC resources.qrc)

set(gridwindow_SOURCES gridwindow.cpp kakoune_client.h kakoune_server.h kakoune_client_factory.h)
qt_add_resources(gridwindow_QRC resources.qrc)

add_executable(singlewindow ${singlewindow_SOURCES} ${singlewindow_QRC})
target_link_libraries(singlewindow PRIVATE Qt::Core Qt::Qml Qt::Quick)

add_executable(splitwindow ${splitwindow_SOURCES} ${splitwindow_QRC})
target_link_libraries(splitwindow PRIVATE Qt::Core Qt::Qml Qt::Quick)

add_executable(gridwindow ${gridwindow_SOURCES} ${gridwindow_QRC})
target_link_libraries(gridwindow PRIVATE Qt::Core Qt::Qml Qt::Quick)

