<?xml version="1.0" encoding="utf-8"?>
<?AutomationStudio FileVersion="4.9"?>
<SwConfiguration CpuAddress="" xmlns="http://br-automation.co.at/AS/SwConfiguration">
  <TaskClass Name="Cyclic#1">
    <Task Name="iotrcrun" Source="Core.Services.IO.iotrcrun.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="Timehandle" Source="Core.Services.Time.Timehandler.prg" Memory="UserROM" Description="Time Handler " Language="IEC" Debugging="true" />
    <Task Name="procinit" Source="App.Application.procinit.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FastLogic" Source="App.Application.Fox_Logic.FastLogic.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Wheelie_Te" Source="App.Application.Jedk.Jedk-Function.Wheelie_Test.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="All_IO_TC1" Source="App.Application.Jedk.Jedk-Function.All_IO_TC1.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="utf82UC" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <Task Name="PrinterCo1" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <Task Name="PrinterCom" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#2">
    <Task Name="fileDevHan" Source="Core.Services.File.fileDevHandler.prg" Memory="UserROM" Description="FileDeviceHandler for USB Stick" Language="IEC" Debugging="true" />
    <Task Name="CoreLinkCf" Source="App.CoreLink.CoreLinkCfg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="coreLinker" Source="Core.Services.CoreLink.coreLinker.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="config" Source="App.Machine.config.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="SafetyPlcA" Source="Core.Services.Alarms.SafetyPlcAlarm.prg" Memory="UserROM" Description="Safety Plc Handler" Language="IEC" Debugging="true" />
    <Task Name="main" Source="App.Machine.main.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="metricon" Source="App.Application.Com_To_Conveyor.metricon.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="MetriconSe" Source="App.Application.Com_To_Conveyor.MetriconSerial.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="procmgr" Source="App.Application.procmgr.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FeedTyp" Source="App.Application.Fox_Logic.FeedTyp.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Accum" Source="App.Application.Fox_Logic.Accum.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="h_inlet" Source="App.Application.Fox_Logic.h_inlet.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="m_inlet" Source="App.Application.Fox_Logic.m_inlet.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="h_opener" Source="App.Application.Fox_Logic.h_opener.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="duo_inlet" Source="App.Application.Fox_Logic.duo_inlet.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Top_Convey" Source="App.Application.Fox_Logic.Top_Conveyor.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="lateral" Source="App.Application.Fox_Logic.lateral.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="crossa" Source="App.Application.Fox_Logic.crossa.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="crossb" Source="App.Application.Fox_Logic.crossb.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="stacker" Source="App.Application.Fox_Logic.stacker.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="outlet" Source="App.Application.Fox_Logic.outlet.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Com_bus" Source="App.Application.Com_To_Conveyor.Com_bus.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="axis" Source="App.Application.Jedk.Acopos.axis.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="MasterAco" Source="App.Application.Jedk.Acopos.MasterAco.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="speed" Source="App.Application.Jedk.Jedk-Function.speed.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="delivery" Source="App.Application.Fox_Logic.delivery.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="XtremeHeav" Source="App.Application.Fox_Logic.XtremeHeavy.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Jedkadapt" Source="App.Application.Jedk.Jedk-Function.Jedkadapt.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="MachineSto" Source="App.Application.Jedk.Jedk-Function.MachineStop.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="HangerSetu" Source="App.Application.Jedk.Jedk-Function.HangerSetup.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="All_IO" Source="App.Application.Jedk.Jedk-Function.All_IO.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Simulation" Source="App.Machine.Simulation.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#3">
    <Task Name="jenlog" Source="App.Application.Fox_Logic.jenlog.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="JenLogStac" Source="App.Application.Fox_Logic.JenLogStack.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="recpedit" Source="App.Application.HMIControl.recpedit.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="auto_prg" Source="App.Application.HMIControl.auto_prg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Safety" Source="Core.Services.Safety.Safety.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="SafetyAlar" Source="Core.Services.Safety.SafetyAlarms.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#4">
    <Task Name="jdserver" Source="Core.Services.BI.BlackBox.jdserver.prg" Memory="UserROM" Description="JenData Configuration,Binding and Server task" Language="IEC" Debugging="true" />
    <Task Name="jdlogger" Source="Core.Services.BI.BlackBox.jdlogger.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="statistics" Source="Core.Services.BI.Statistics.statistics.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="SerialSrv" Source="Core.Services.Communication.ConnectionHandler.SERIAL.SerialSrv.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="AlarmHandl" Source="Core.Services.Alarms.AlarmHandler.prg" Memory="UserROM" Description="HMI Alarm Handling and Service Log" Language="IEC" Debugging="true" />
    <Task Name="HistoryAla" Source="Core.Services.Alarms.HistoryAlarm.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="HMIHandler" Source="Core.Services.HMI.HMIHandler.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="OPCHandler" Source="Core.Services.BI.OPC.OPCHandler.prg" Memory="UserROM" Description="OPC Handler" Language="IEC" Debugging="true" />
    <Task Name="Connection" Source="Core.Services.Communication.ConnectionManager.ConnectionManager.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="BnRXMLRPC" Source="Core.Services.Communication.XMLRPCServer.BnRXMLRPC.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FlatXMLSrv" Source="Core.Services.Communication.ConnectionHandler.FLATXML.FlatXMLSrv.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="JenTransSr" Source="Core.Services.Communication.ConnectionHandler.JENTRANS.JenTransSrv.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FoldXMLSrv" Source="Core.Services.Communication.ConnectionHandler.FOLDXML.FoldXMLSrv.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="ANLogic" Source="Core.Services.Communication.ConnectionLogic.ArcNet.ANLogic.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="AutoProgCo" Source="App.Application.HMIControl.AutoProgConv.prg" Memory="UserROM" Language="IEC" Debugging="true" Disabled="true" />
    <Task Name="Interconne" Source="Core.Services.Communication.ConnectionLogic.JensenInterCom.InterconnectHandler.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="M2M" Source="Core.Services.Communication.ConnectionLogic.M2MLogic.M2M.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Timezone" Source="Core.Services.Time.Timezone.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="DaylightSa" Source="Core.Services.Time.DaylightSaving.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="sntpHandle" Source="Core.Services.Time.sntpHandler.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="RealTime" Source="Core.Services.BI.BlackBox.SQL.RealTime.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="CockpitLog" Source="Core.Services.BI.BlackBox.SQL.CockpitLog.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="CockpitCom" Source="Core.Services.Communication.ConnectionLogic.Cockpit.CockpitCom.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="MetriconIO" Source="App.Application.Com_To_Conveyor.MetriconIO.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="cfgedit" Source="App.Application.HMIControl.cfgedit.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="recpedit2" Source="App.Application.HMIControl.recpedit.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="service" Source="App.Application.HMIControl.service.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="statalarms" Source="App.Application.HMIControl.statalarms.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="sel_rcp" Source="Core.Services.Configuration.rcfg.sel_rcp.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="op_pageh" Source="App.Application.HMIControl.op_pageh.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FileManage" Source="App.Application.HMIControl.FileManager.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="PrinterXML" Source="App.Application.Com_To_Conveyor.PrinterXMLCom.prg" Memory="UserROM" Language="ANSIC" AdditionalIncludeDirectories="\Logical\Core\Libraries\LibraryIncludes\" AdditionalLibraryDirectories="\Logical\Core\Libraries\LibraryIncludes\" AdditionalLibraries="rtk_lib" Debugging="true" Disabled="true" />
    <Task Name="Trace2File" Source="App.Application.Jedk.Trace2File.Trace2FileTask.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="check_IO" Source="App.Machine.check_IO.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="xml_jenw" Source="Core.Services.Communication.Jenway.xml_jenw.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#5" />
  <TaskClass Name="Cyclic#6" />
  <TaskClass Name="Cyclic#7">
    <Task Name="ipcfg" Source="Core.Services.Communication.Utilities.ipcfg.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="pancfg" Source="Core.Services.Configuration.pancfg.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="XML_HMI_Di" Source="App.Application.Com_To_Conveyor.XML_HMI_Diag.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="plclog" Source="Core.Services.File.plclog.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="recpedit1" Source="App.Application.HMIControl.recpedit.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="password" Source="Core.Services.HMI.password.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="IOAlarm" Source="Core.Services.Alarms.IOAlarm.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="InverterAl" Source="Core.Services.Alarms.InverterAlarm.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="busstat" Source="Core.Services.IO.busstat.prg" Memory="UserROM" Description="Busstat Handler" Language="IEC" Debugging="true" />
    <Task Name="AcoposAlar" Source="Core.Services.Alarms.AcoposAlarm.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="FileAlarm" Source="Core.Services.Alarms.FileAlarm.prg" Memory="UserROM" Description="HMI File Alarm Handling" Language="IEC" Debugging="true" />
    <Task Name="BBTest" Source="Core.UnitTests.CockpitTest.BBTest.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="settingstr" Source="App.Machine.settingstrig.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="IOTServer" Source="Modules.IOT.Logic.IOTServer.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="GLiteV2" Source="Modules.IOT.Logic.GLiteV2.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="IOTTwinV2" Source="Modules.IOT.Logic.IOTTwinV2.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#8">
    <Task Name="iotrccfg" Source="Core.Services.IO.iotrccfg.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="iostatus" Source="Core.Services.IO.iostatus.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="system" Source="Core.Services.Configuration.system.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="rcfg" Source="Core.Services.Configuration.rcfg.rcfg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="rcfgMan" Source="Core.Services.Configuration.rcfg.rcfgMan.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="mcfg" Source="Core.Services.Configuration.mcfg.mcfg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="mcfgMan" Source="Core.Services.Configuration.mcfg.mcfgMan.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="hcfg" Source="Core.Services.Configuration.hcfg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="CAR" Source="Core.Services.Configuration.CAR.prg" Memory="UserROM" Description="HMI CAR Handler" Language="IEC" Debugging="true" />
    <Task Name="acfg" Source="Core.Services.Configuration.acfg.acfg.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="oplist" Source="Core.Services.Configuration.oplist.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="backup" Source="Core.Services.File.backup.prg" Memory="UserROM" Language="IEC" Debugging="true" Version="1.00.0" />
    <Task Name="tasklist" Source="Core.Services.File.tasklist.prg" Memory="UserROM" Description="HMI Task information Handling" Language="IEC" Debugging="true" />
    <Task Name="PrinterHMI" Source="App.Application.Com_To_Conveyor.PrinterHMICom.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="TimerVisib" Source="App.Machine.TimerVisibility.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <DataObjects>
    <DataObject Name="HMIPatch" Source="App.CoreLink.HMI.HMIPatch.dob" Memory="UserROM" Description="HMI Patch File Denmark" Language="Simple" />
    <DataObject Name="vismenu" Source="HMI.vismenu.dob" Memory="UserROM" Description="JEHMI Handler menu data (VIS)" Language="Simple" />
    <DataObject Name="HMIPatchRe" Source="App.CoreLink.HMI.HMIPatchRemote.dob" Memory="UserROM" Language="Simple" />
    <DataObject Name="xmldata" Source="Core.Services.Communication.XMLRPCServer.XMLRPCConfiguration.xmldata.dob" Memory="UserROM" Description="M2M Sax-RPC Configuration" Language="Simple" />
    <DataObject Name="xmsvrcfg" Source="Core.Services.Communication.XMLRPCServer.XMLRPCConfiguration.xmsvrcfg.dob" Memory="UserROM" Description="M2M Server Configuration" Language="Simple" />
    <DataObject Name="Version" Source="Core.Version.dob" Memory="UserROM" Language="Simple" />
    <DataObject Name="Acp10sys" Source="" Memory="UserROM" Language="Binary" />
    <DataObject Name="arsdmsvp" Source="" Memory="UserROM" Language="Binary" />
    <DataObject Name="arsdmhtm" Source="" Memory="UserROM" Language="Binary" />
    <DataObject Name="arsdmsvg" Source="" Memory="UserROM" Language="Binary" />
  </DataObjects>
  <NcDataObjects>
    <NcDataObject Name="230par" Source="App.Application.Jedk.Acopos.230par.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="400par" Source="App.Application.Jedk.Acopos.400par.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gServoHang" Source="App.Application.Jedk.Acopos.gServoHanger.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="acp10etxen" Source="App.Application.Jedk.Acopos.acp10etxen.dob" Memory="UserROM" Language="Ett" />
    <NcDataObject Name="gAxis01a" Source="App.Application.Jedk.Acopos.gAxis01a.dob" Memory="UserROM" Language="Apt" />
  </NcDataObjects>
  <VcDataObjects>
    <VcDataObject Name="Master" Source="HMI.Master.dob" Memory="UserROM" Language="vc" Version="1.00.0" WarningLevel="3" />
    <VcDataObject Name="duo" Source="App.DuoVis.duo.dob" Memory="UserROM" Language="Vc" Disabled="true" WarningLevel="2" />
  </VcDataObjects>
  <Binaries>
    <BinaryObject Name="Master01" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Master02" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Master03" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccnum" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vctcal" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccovl" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfile" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccline" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arial" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcgclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccstr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcrt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccdbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcclbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbmp" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbtn" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfntttf" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsint" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccshape" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcchspot" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arialbd" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcmgr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsloc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcctext" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="visvc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccdt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbar" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcshared" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdsw" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcbclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcnet" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdvnc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="udbdef" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="TCData" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="vcpfgen" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Acp10cfg" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Acp10map" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="sysconf" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="asfw" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="ashwd" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="arconfig" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="iomap" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="ashwac" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfar00" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfpp30" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfmtcx" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcptelo" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdpp30" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arialu_1" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="plasti_1" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="troglo_1" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="mesagr_1" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="magnetob" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="ariblk" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arsdm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="webserv" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcbmpng" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="mvLoader" Source="" Memory="UserROM" Language="Binary" />
  </Binaries>
  <Libraries>
    <LibraryObject Name="standard" Source="Core.Libraries.BRLibraries.standard.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="runtime" Source="Core.Libraries.BRLibraries.runtime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="OPERATOR" Source="Core.Libraries.BRLibraries.OPERATOR.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Util" Source="App.Application.Jedk.Util.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="FileIO" Source="Core.Libraries.BRLibraries.FileIO.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="DVFrame" Source="Core.Libraries.BRLibraries.DVFrame.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="DataObj" Source="Core.Libraries.BRLibraries.DataObj.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="brsystem" Source="Core.Libraries.BRLibraries.brsystem.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsTime" Source="Core.Libraries.BRLibraries.AsTime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsTCP" Source="Core.Libraries.BRLibraries.AsTCP.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsString" Source="Core.Libraries.BRLibraries.AsString.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMem" Source="Core.Libraries.BRLibraries.AsMem.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsIOMMan" Source="Core.Libraries.BRLibraries.AsIOMMan.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsIODiag" Source="Core.Libraries.BRLibraries.AsIODiag.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="SYS_LIB" Source="Core.Libraries.BRLibraries.SYS_LIB.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsIO" Source="Core.Libraries.BRLibraries.AsIO.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsHW" Source="Core.Libraries.BRLibraries.AsHW.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsARCfg" Source="Core.Libraries.BRLibraries.AsARCfg.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsUSB" Source="Core.Libraries.BRLibraries.AsUSB.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="EthSock" Source="Core.Libraries.BRLibraries.EthSock.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsICMP" Source="Core.Libraries.BRLibraries.AsICMP.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsDb" Source="Core.Libraries.BRLibraries.AsDb.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="BIT_USINT" Source="App.Application.Libraries.BIT_USINT.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="BRSE_STF" Source="App.Application.Libraries.BRSE_STF.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="FoldTool" Source="App.Application.Libraries.FoldTool.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Fox" Source="App.Application.Libraries.Fox.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JenPanel" Source="App.Application.Libraries.JenPanel.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="LibProc" Source="App.Application.Libraries.LibProc.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MetLogic" Source="App.Application.Libraries.MetLogic.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="ScanLib" Source="App.Application.Libraries.ScanLib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMath" Source="Core.Libraries.BRLibraries.AsMath.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10man" Source="Core.Libraries.Acp10man.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="NcGlobal" Source="Core.Libraries.NcGlobal.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10par" Source="Core.Libraries.Acp10par.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Kc" Source="App.Application.Jedk.Acopos.Kc.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="Acp10_MC" Source="Core.Libraries.Acp10_MC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Trace2Lib" Source="App.Application.Jedk.Trace2File.Trace2Lib.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="itoxlib" Source="App.Application.Jedk.Trace2File.itoxlib.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="Visapi" Source="Core.Libraries.BRLibraries.Visapi.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MetUtils" Source="Core.Libraries.CoreLibraries.MetUtils.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JEDKLIB" Source="Core.Libraries.CoreLibraries.JEDKLIB.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="base64" Source="Core.Libraries.CoreLibraries.base64.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CacheLib" Source="Core.Libraries.CoreLibraries.CacheLib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CLib" Source="Core.Libraries.CoreLibraries.CLib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CMSupport" Source="Core.Libraries.CoreLibraries.CMSupport.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CRC" Source="Core.Libraries.CoreLibraries.CRC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="IoList" Source="Core.Libraries.CoreLibraries.IoList.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="jedata" Source="Core.Libraries.CoreLibraries.jedata.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JEGR_Coop" Source="Core.Libraries.CoreLibraries.JEGR_Coop.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JEHMI" Source="Core.Libraries.CoreLibraries.JEHMI.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JenSQL" Source="Core.Libraries.CoreLibraries.JenSQL.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="jercp" Source="Core.Libraries.CoreLibraries.jercp.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="ListHand" Source="Core.Libraries.CoreLibraries.ListHand.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="LogLib" Source="Core.Libraries.CoreLibraries.LogLib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MetIDUtils" Source="Core.Libraries.CoreLibraries.MetIDUtils.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsUDP" Source="Core.Libraries.AsUDP.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="AsETH" Source="Core.Libraries.AsETH.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="dispatch" Source="Core.Libraries.CoreLibraries.XMLCom.dispatch.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="FlatXML" Source="Core.Libraries.CoreLibraries.XMLCom.FlatXML.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="FoldXML" Source="Core.Libraries.CoreLibraries.XMLCom.FoldXML.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="httpUtil" Source="Core.Libraries.CoreLibraries.XMLCom.httpUtil.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JenTrans" Source="Core.Libraries.CoreLibraries.XMLCom.JenTrans.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="JenVar" Source="Core.Libraries.CoreLibraries.XMLCom.JenVar.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="jenxml" Source="Core.Libraries.CoreLibraries.XMLCom.jenxml.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="rpc2d" Source="Core.Libraries.CoreLibraries.XMLCom.rpc2d.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="SAX_RPC" Source="Core.Libraries.CoreLibraries.XMLCom.SAX_RPC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XML" Source="Core.Libraries.CoreLibraries.XMLCom.XML.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XML_clnt" Source="Core.Libraries.CoreLibraries.XMLCom.XML_clnt.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XML_Interf" Source="Core.Libraries.CoreLibraries.XMLCom.XML_Interf.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XML_IVs" Source="Core.Libraries.CoreLibraries.XMLCom.XML_IVs.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XML_Mrsh" Source="Core.Libraries.CoreLibraries.XMLCom.XML_Mrsh.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XMLPVs" Source="Core.Libraries.CoreLibraries.XMLCom.XMLPVs.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="XMLRPC" Source="Core.Libraries.CoreLibraries.XMLCom.XMLRPC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsIecCon" Source="Core.Libraries.AsIecCon.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="AsBrStr" Source="Core.Libraries.BRLibraries.AsBrStr.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="ArTextSys" Source="Modules.Backbone.Libraries.ArTextSys.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="rtk" Source="Modules.Backbone.Libraries.rtk.lby" Memory="None" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsSafety" Source="Core.Libraries.AsSafety.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="AsXml" Source="Core.Libraries.AsXml.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="brdkSafety" Source="Core.Libraries.BRLibraries.brdkSafety.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="brdkSTR" Source="Modules.Backbone.Libraries.brdkSTR.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="AsIOAcc" Source="Core.Libraries.AsIOAcc.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="AsEPL" Source="Core.Libraries.AsEPL.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="brdkMU" Source="Core.Libraries.BRLibraries.brdkMU.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="AsSem" Source="Core.Libraries.AsSem.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="BRSE_RTK" Source="Modules.IOT.Libraries.BRSE_RTK.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsHost" Source="Modules.IOT.Libraries.AsHost.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="ArEventLog" Source="Modules.IOT.Libraries.ArEventLog.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="AsBrMath" Source="Modules.IOT.Libraries.AsBrMath.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="IotMqtt" Source="Modules.IOT.Libraries.IotMqtt.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsSMTP" Source="Modules.IOT.Libraries.AsSMTP.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="peek" Source="Modules.IOT.Libraries.peek.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="AzureUtils" Source="Modules.IOT.Libraries.AzureUtils.lby" Memory="UserROM" Language="ANSIC" Debugging="true" />
    <LibraryObject Name="DiffCount" Source="Modules.IOT.Libraries.DiffCount.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="vcresman" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="powerlnk" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="arcert" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="arssl" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
  </Libraries>
</SwConfiguration>