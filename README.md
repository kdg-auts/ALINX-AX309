# Лабораторный практикум - плата ALINX-AX309

Набор проектов для ознакомления с ресурсами учебной отладочной платы ALINX AX309.
Основной элемент платы - микросхема FPGA семейства Xilinx Spartan 6, модель XC6SLX9.  
Подробное описание ресурсов платы, используемой микросхемы FPGA и приемов работы с платой можно найти в [Wiki](https://github.com/kdg-auts/ALINX-AX309/wiki).

## lab0 - Ознакомительная лабораторная работа

**Цель работы:** ознакомление со средой проектирования (Xilinx ISE Design Suite), освоение типового процесса проектирования цифровой системы под каждое из семейств ПЛИС FPGA (Spartan 6) на примере реализации подстановочного блока для алгоритма шифрования ГОСТ 28147-89; научиться описывать простые устройства комбинацинного типа на языке VHDL.

**Задачи:**
1. Теоретическая разработка решения, подготовка описания на языке VHDL.
1. Создание и поддержка проекта, задание настроек и параметров.
1. Ввод описаний и управление исходным кодом проекта.
1. Организация процессов моделирования и функциональной верификации разработанных решений.
1. Настройка и выполнение всех технологических процессов синтеза. Задание проектных ограничений.
1. Подготовка и выполнение процесса конфигурирования ПЛИС на отладочной плате. Создание перманентной конфигурации (запись конфигурации в служебную энергонезависимую память FLASH).

**Задействованные ресурсы:**
* 4 кнопки
* 4 светодиода



## lab1 - Работа с простейшими ресурсами ввода/вывода

**Цель работы:** научиться правильно обрабатывать ввод данных с кнопок и обеспечивать различные режимы индикации на светодиодах; научиться описывать устройства с внутренними состояниями: автоматы, счетчики

**Задачи:**
1. Реализовать модуль считывания данных с набора пользовательских кнопок на отладочной плате с учетом дребезга контактов. Модуль должен распознавать кратковременные и долговременные нажатия, вырабатывать сигналы событий "нажатие" и "отпускание" кнопки. Не зависимо от схемы подключения кнопки к выводу ПЛИС, сигнал о нажатии должен выдаваться в прямой логике (1 - кнопка нажата, 0 - кнопка не нажата)
1. Реализовать модуль вывода сигналов на светодиоды с несколькими режимами отображения: светодиод подсвечивается постоянно, светодиод работает в мигающем режиме с низкой частотой мигания (с периодом около секунды) и с высокой частотой мигания (период около 100 миллисекунд)

**Задействованные ресурсы:**
* 4 кнопки
* 4 светодиода



## lab2 - Работа с звукоизлучателем

**Цель работы:** научиться работать с активным и пассивным звукоизлучателем; научиться формировать различные варианты звуковых сигналов; научиться повторно использовать ранее описанные модули

**Задачи:**
1. Реализовать модуль формирования различных видов звуковых сигналов: кратковременный, длительный, двойной кратковременный.
1. Интегрировать разработанные ранее модули для кнопок и светодиодов в проект с звукоизлучателем 

**Задействованные ресурсы:**
* 4 кнопки
* 4 светодиода
* пьезоэлектрический звукоизлучатель



## lab3 - Работа с семисегментным символьно-цифровым светодиодным индикатором

**Цель работы:** научиться работать с семисегментным символьно-цифровым светодиодным индикатором; научиться повторно использовать ранее описанные модули; научиться грамотно применять при разработке цифровые автоматы

**Задачи:**
1. Реализовать модуль драйвера n-разрядного семисегментного символьно-цифрового светодиодного индикатора
1. Интегрировать разработанные ранее модули для работы с кнопками, светодиодами и звукоизлучателем в проект
1. Реализовать управляющий автомат, который обеспечивает возможность произвольного задавания отображаемых на семисегментных индикаторах чисел; выбор позиции на индикаторе и смену отображаемого числа в порядке убывания или возрастания должны выполняться с помощью пользовательских кнопок, индикацию выбранной позиции осуществлять с помощью индикатора десятичной точки; изменение значения в выбранном сегменте сопровождать с помощью звукового сигнала. 

**Альтернативное задание (повышенной сложности):**
Обеспечить разграничение режимов смены индикатора и редактирования отображаемого числа: смену индикаторов осуществлять по короткому нажатию кнопок KEY1 и KEY2, включение режима смены значения выполнять по долгому нажатию кнопки KEY3, вход в режим редактирования сопровождать длинным звуковым сигналом; после входа в режим редактирования кнопки KEY1 и KEY2 должны обеспечивать смену значений выбранного сегмента; выход из режима редактирования (переход в режим выбора сегмента) осуществлять по долгому нажатию на кнопку KEY3, выход из режима сопровождать длинным звуковым сигналом; активный сегмент отображать постоянным свечением десятичной точки, в режиме редактированя - миганием десятичной точки с периодом 1 сек.

**Задействованные ресурсы:**
* 4 кнопки
* 6-позиционный семисегментный символьно-цифровой светодиодный индикатор
* пьезоэлектрический звукоизлучатель



## lab4 - Работа с универсальным портом последовательной передачи данных (UART)

**Цель работы:** научиться выполнять информационный обмен между ПК и отладочным комплексом на базе ПЛИС используя универсальный последовательный приемо-передатчик (UART); научиться проектировать сложные устройства с собственными управляющими автоматами и научиться согласовывать их взаимодействие; научиться продумывать, реализовывать и грамотно применять протоколы связи

**Задачи:**
1. Реализовать модуль драйвера универсального последовательного приемо-передатчика (UART)
1. Интегрировать разработанные ранее модули по работе с задействованной периферией в проект
1. Реализовать систему, включая необходимые интерфейсные модули, схемы памяти и управляющие автоматы, которая позволяет хранить многоразрядный вектор данных, изменять его состояние с визуальным контролем на 7-сегментном светодиодном индикаторе, а также отправлять на ПК текущее состояние этого вектора и получать новое состояние по командам, посылаемым по интерфейсу UART. Проект предполагает использование системы, спроектированной в лабораторной работе lab3.

При необходимости отладки и проверки работы модуля приемо-передатчика использовать логический анализатор.

**Задействованные ресурсы:**
* 4 кнопки
* 6-позиционный семисегментный символьно-цифровой светодиодный индикатор
* пьезоэлектрический звукоизлучатель
* микросхема преобразователя UART-USB CP2102 и разьем mini-USB для подключения к ПК

На ПК потребуется установка драйвера по работе с микросхемой CP2102 (если еще он не установлен) и прикладное ПО по работе с последовательным портом (рекомендуется программа Terminal или аналогичные)


## lab5 - Работа с микросхемой энергонезависимой памяти (EEPROM)

**Цель работы:** научиться работать с внешней энергонезависимой памятью (EEPROM): сохранять прикладные данные до отключения питания устройства и восстанавливать их после вознобновления питания; научиться работать с двухпроводным интерфейсом связи I2C (TWI); закрепить навыки проектирования сложных устройств с собственными управляющими автоматами и согласовывания их взаимодействий; научиться продумывать, реализовывать и грамотно применять форматы сохранения данных в устройствах памяти

**Задачи:**
1. Реализовать модуль драйвера приема-передачи по интерфейсу I2C (TWI), выполнить его проверку и отладку с использованием необходимых технических и программных средств
1. Интегрировать разработанные ранее модули по работе с необходимой периферией в проект
1. Реализовать систему, которая позволяет хранить многоразрядный вектор данных, изменять его состояние с визуальным контролем на 7-сегментном светодиодном индикаторе, а также сохранять в энергонезависимую память текущее состояние этого вектора и восстанавливать это состояние после включения или сброса системы по командам пользователя. Проект предполагает использование системы, спроектированной в лабораторной работе lab3. В качестве команд на сохранение и восстановление предлагается использование продолжительного нажатия тех кнопок, по которым такое нажатие еще не задействовано.

**Альтернативное задание (повышенной сложности):**
Построить систему с сохранением и восстановлением состояния на базе проекта из лабораторной работы lab4, т.е. в системе должны одновременно быть использованы как сохранение/восстановление, так и прием/передача состояния по интерфейсу UART. Реализовать механизм сохранения/восстановления состояния по команде, передаваемой по интерфейсу UART.

**Задействованные ресурсы:**
* 4 кнопки
* 6-позиционный семисегментный символьно-цифровой светодиодный индикатор
* пьезоэлектрический звукоизлучатель
* микросхема электрически стираемого ПЗУ (EEPROM) AT24C04

Для реализации альтернативного задания должна быть задействована микросхема преобразователя UART-USB CP2102 и разьем mini-USB для подключения к ПК. При отладке и проверке правильности функционирования можно задействовать логический анализатор и специализированное средство внутрикристальной отладки ChipScope Pro.


## lab6 - Работа с интерфейсом вывода видеосигнала на экран (VGA)

**Цель работы:** 

**Задачи:**

**Задействованные ресурсы:**
