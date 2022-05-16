find_package(Qt5 ${QT_REQUIRED_VERSION} CONFIG REQUIRED Core Qml Quick)

set(singlewindow_SOURCES singlewindow.cpp kakoune_client.h kakoune_server.h)
qt5_add_resources(singlewindow_QRC resources.qrc)

set(splitwindow_SOURCES splitwindow.cpp kakoune_client.h kakoune_server.h kakoune_alive_client_counter.h)
qt5_add_resources(splitwindow_QRC splitwindow_resources.qrc)

add_executable(singlewindow ${singlewindow_SOURCES} ${singlewindow_QRC})
target_link_libraries(singlewindow Qt5::Core Qt5::Qml Qt5::Quick)

add_executable(splitwindow ${splitwindow_SOURCES} ${splitwindow_QRC})
target_link_libraries(splitwindow Qt5::Core Qt5::Qml Qt5::Quick)
