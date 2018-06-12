find_package(Qt5 ${QT_REQUIRED_VERSION} CONFIG REQUIRED Core Qml Quick)

set(kakouneqml_SOURCES main.cpp kakoune_client.h)

qt5_add_resources(kakouneqml_QRC resources.qrc)

add_executable(kakouneqml ${kakouneqml_SOURCES} ${kakouneqml_QRC})
target_link_libraries(kakouneqml Qt5::Core Qt5::Qml Qt5::Quick)
