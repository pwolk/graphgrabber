unit main;

{$mode objfpc}{$H+}

{
The Clear BSD License

Copyright (c) 1996-2016, Pieter van der Wolk
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted (subject to the limitations in the disclaimer
below) provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS
LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.
}

interface

//check whether the axes are independent
//check whether the drawn lines are independent
//extra tests for log axes
//make axes perpendicular
//update all coordinate definitions when switching to datagrabbing
//non-perpendicular axes are not right
// default values for axes
// clear the memory of the bitmap

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Menus, lclintf;

type

  { TfmMain }

  TfmMain = class(TForm)
    chkXlog: TCheckBox;
    chkYlog: TCheckBox;
    edPixelX: TEdit;
    edPixelY: TEdit;
    edCoordinateY: TEdit;
    edCoordinateX: TEdit;
    edY2YAxis: TEdit;
    edX1Origin: TEdit;
    edY1Origin: TEdit;
    edX1XAxis: TEdit;
    imgGraph: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    lstGrabbedData: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    btnOpenImage: TMenuItem;
    MenuSave: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    mnuAbout: TMenuItem;
    dlgOpenImage: TOpenDialog;
    pnlBottom: TPanel;
    RightPanel: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    btnSetAxes: TToggleBox;
    TopPanel: TPanel;
    procedure btnSetAxesChange(Sender: TObject);
    procedure edX1OriginExit(Sender: TObject);
    procedure edX1XAxisChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgGraphClick(Sender: TObject);
    procedure imgGraphMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgGraphMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgGraphMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lstGrabbedDataChange(Sender: TObject);
    procedure btnOpenImageClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure ProcessIniFile(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    fDrawing : BOOLEAN;
    ptOrigin, ptMove, ptE1, ptE2, ptTemp : TPoint;
    ptFrOriginX, ptFrOriginY, // Fr denotes a fraction of the imagewidth or height
    ptFrClickedX, ptFrClickedY,
    ptFrE1X, ptFrE1Y,
    ptFrE2X, ptFrE2Y : single;
    sglGrabbedXValue,  sglGrabbedYValue  : single;
  end;

Const
  strIniFileName = 'GraphGrabber.ini';
  strIni1        = 'This file contains the settings for the datagrabber program.';
  strIni2        = '';
  strIni3        = 'OpenDirectory = c:\';
  strIni4        = 'SaveDirectory = c:\';
  strIni5        = '';
  strIni6        = 'formatxdata   = 0.0000';
  strIni7        = 'formatydata   = 0.0000';
  strIni8        = 'DefaultXOrigin      = 0';
  strIni9        = 'DefaultYOrigin      = 0';
  strIni10       = 'DefaultXMax         = 1';
  strIni11       = 'DefaultYMax         = 1';
  strIni12       = 'DefaultXOriginLog   = 0.1';
  strIni13       = 'DefaultYOriginLog   = 0.1';
  strIni14       = 'DefaultXMaxLog      = 100';
  strIni15       = 'DefaultYMaxLog      = 100';
  strIni16       = 'XAxisIsLog      = FALSE';
  strIni17       = 'YAxisIsLog      = FALSE';
  strIni18       = 'WriteFileNameInData = FALSE';
  iPenWidthFactor = 10;
  strVersion     = 'Version 0.33';

var
  fmMain: TfmMain;
  fAxesPerpendicular : boolean;
  sglX1Origin, sglY1Origin, sglX1XAxis, sglY1XAxis : single  ;
  sglX2Origin, sglY2Origin, sglX2XAxis, sglY2XAxis : single  ;
  // default values for the above parameters
  sglX1OriginD, sglY1OriginD, sglX1XAxisD, sglY1XAxisD : single  ;
  sglX2OriginD, sglY2OriginD, sglX2XAxisD, sglY2XAxisD : single  ;
  iSetAxesSequence : integer;
  fDrawState : BOOLEAN;
  fBothAxesDefined : BOOLEAN;

  //
  sglXAxisMin, sglXAxisMax, sglYAxisMin, sglYAxisMax : single;
  StrFormatDigitsX, StrFormatDigitsY : string;

  strDefaultX1Origin, strDefaultX1XAxis,
  strDefaultY1Origin, strDefaultY1YAxis,
  strDefaultX1OriginLog, strDefaultX1XAxisLog,
  strDefaultY1OriginLog, strDefaultY1YAxisLog : string;  //default values
  fWriteFileNameInData : Boolean;


implementation

{$R *.lfm}

{ TfmMain }

procedure TfmMain.lstGrabbedDataChange(Sender: TObject);
begin

end;



procedure TfmMain.btnSetAxesChange(Sender: TObject);
var
  fKosher : boolean;
begin
  fKosher := true;
  //check state
  if btnSetAxes.Checked then
  begin
    //check numbers
    if edX1Origin.color = clRed then fKosher := false;
    if edY1Origin.color = clRed then fKosher := false;
    if edX1XAxis.color = clRed then fKosher := false;
    if edY2YAxis.color = clRed then fKosher := false;

    // check if the log scale has negative numbers
    if chkXlog.checked then
    begin
      if (not (StrToFloat(edX1Origin.text) > 0) ) then
      begin
        fKosher := false;
        chkXlog.checked := false;
      end;
    end;
    if (not (StrToFloat(edX1XAxis.text) > 0) )    then
    begin
      fKosher := false;
      chkXlog.checked := false;
    end;
    if chkYlog.checked then
    begin
      if (not (StrToFloat(edY1Origin.text) > 0) ) then
      begin
        fKosher := false;          //edY1Origin.text := strDefaultY1OriginLog;
        chkYlog.checked := false;
      end;

      if (not (StrToFloat(edY2YAxis.text) > 0) ) then
      begin
        fKosher := false;          //edY1Origin.text := strDefaultY1OriginLog;
        chkYlog.checked := false;
      end;
    end;
    //check if axes have been defined
    {if ptE1.x = -100 then
    begin
      fKosher := false;
      lstGrabbedData.lines.Add('(Define axes first)');
    end;   }
    if fBothAxesDefined = false then
    begin
      fKosher := false;
      lstGrabbedData.lines.Add('(Define axes first)');
    end;
  if fKosher then
  begin
    edX1Origin.enabled :=false;
    edY1Origin.enabled :=false;
    edX1XAxis.enabled :=false;
    edY2YAxis.enabled :=false;
    //clear axes?
    //write numbers along axes?

    // if no axes defined, this isn't working
    sglXAxisMin := StrToFloat(edX1Origin.Text);
    sglXAxisMax := StrToFloat(edX1XAxis.Text);
    sglYAxisMin := StrToFloat(edY1Origin.Text);
    sglYAxisMax := StrToFloat(edY2YAxis.Text);

    btnSetAxes.caption := 'Grab data';
    fmMain.caption := 'Graph Grabber - data grabbing stage';
  end
  else
  begin
    btnSetAxes.Checked := false;
    edX1Origin.enabled :=true;
    edY1Origin.enabled :=true;
    edX1XAxis.enabled :=true;
    edY2YAxis.enabled :=true;
    //btnSetAxesClick(Sender);
    {sglXAxisMin := StrToFloat(edX1Origin.Text);
    sglXAxisMax := StrToFloat(edX1XAxis.Text);
    sglYAxisMin := StrToFloat(edY1Origin.Text);
    sglYAxisMax := StrToFloat(edY2YAxis.Text); }
  end;
  end
   else
   begin
     btnSetAxes.caption := 'Set axes';
     fmMain.caption := 'Graph Grabber - define axes stage';
     fBothAxesDefined := false;
   end;
end;



procedure TfmMain.edX1OriginExit(Sender: TObject);
  var
    txtTemp : string;
    num : single;
begin
  try
    txtTemp :=(Sender As TEdit).text;
    num := StrToFloat(txtTemp);
    (Sender As TEdit).color := clDefault;
   except
    (Sender As TEdit).color := clRed;
   end;
end;

procedure TfmMain.edX1XAxisChange(Sender: TObject);
begin

end;



procedure TfmMain.FormCreate(Sender: TObject);
   var
     Bitmap: TBitmap;	{ temporary variable to hold the bitmap }
   begin
     Bitmap := TBitmap.Create;	{ construct the bitmap object }
     Bitmap.Width := 400;	{ assign the initial width... }
     Bitmap.Height := 400;	{ ...and the initial height }
     imgGraph.Picture.Graphic := Bitmap;	{ assign the bitmap to the image component }
     //imgGraph.Picture.Graphic := nil;
     fDrawState := FALSE;
     fBothAxesDefined := FALSE;
   end;

procedure TfmMain.FormKeyPress(Sender: TObject; var Key: char);
   begin
     if Key = #3 then {= control + c}
     begin
       lstGrabbedData.SelectAll;
       lstGrabbedData.CopyToClipboard;
     end;
     if (Key = #4)  then {= control + d}
     begin
       lstGrabbedData.Clear;
     end;

     if (Key = #46) then {= delete}
     begin
         //if lstGrabbedData.SelText = '' then GrabbedData.Clear;
         //often by mistake... needs warning
     end;
     //lstGrabbedData.lines.add(key);
     if (Key = #20)  then {= control + t , toggle}
     begin    // needs attention
       if btnSetAxes.enabled = true then
         btnSetAxes.enabled := false
        else
         btnSetAxes.enabled := true;
     end;
   end;

procedure TfmMain.FormResize(Sender: TObject);
   begin
     // scale origin and base vectors to the size of the image
     ptFrOriginX   := ptOrigin.X / imgGraph.Width;
     ptFrOriginY   := ptOrigin.Y / imgGraph.Height;
     ptFrE1X       := (ptE1.X - ptOrigin.X)    / imgGraph.Width;     //fraction of the E1 vector in the X direction
     ptFrE1Y       := (ptE1.Y - ptOrigin.Y)   / imgGraph.Height;     // all relative to the image size
     ptFrE2X       := (ptE2.X - ptOrigin.X)   / imgGraph.Width;
     ptFrE2Y       := (ptE2.Y - ptOrigin.Y)   / imgGraph.Height;
     imgGraph.Canvas.Pen.Width := 1; // iPenWidthFactor* imgGraph.Width  div imgGraph.Picture.Graphic.width;
       if imgGraph.Width > imgGraph.Picture.Graphic.width then imgGraph.Canvas.Pen.Width := 1;


   end;

procedure TfmMain.FormShow(Sender: TObject);
   begin

     fAxesPerpendicular := FALSE;
     iSetAxesSequence := 0;
     sglX1OriginD := 0; sglY1OriginD := 0; sglX1XAxisD := 1; sglY1XAxisD := 0;
     sglX2OriginD := 0; sglY2OriginD := 0; sglX2XAxisD := 0; sglY2XAxisD := 1;
     ptOrigin.X := -100;  ptOrigin.Y := -100;
     ptE1.X := -100;      ptE1.Y := -100;
     ptE1.X := -100;      ptE1.Y := -100;
     btnSetAxesChange(Sender);
     StrFormatDigitsX :='0.00000';
     StrFormatDigitsY :='0.00000';
     SaveDialog1.initialDir := 'c:\';
     dlgOpenImage.initialDir := 'c:\';
     strDefaultX1Origin    := '0';
     strDefaultX1XAxis     := '1';
     strDefaultY1Origin    := '0';
     strDefaultY1YAxis     := '1';
     strDefaultX1OriginLog := '0.1';
     strDefaultX1XAxisLog  := '100';
     strDefaultY1OriginLog := '0.1';
     strDefaultY1YAxisLog  := '100';
     ProcessIniFile(Sender);  // may override default settings
     if chkXlog.checked then
     begin
       edX1Origin.text := strDefaultX1OriginLog;
       edX1XAxis.text  := strDefaultX1XAxisLog ;
     end
     else
     begin
       edX1Origin.text := strDefaultX1Origin;
       edX1XAxis.text  := strDefaultX1XAxis ;
     end;
     if chkYlog.checked then
     begin
       edY1Origin.text := strDefaultY1OriginLog;
       edX1XAxis.text  := strDefaultX1XAxisLog ;
     end
     else
     begin
       edY1Origin.text := strDefaultY1Origin;
       edY2YAxis.text  := strDefaultY1YAxis ;
     end;
     //SynchroniseEditBoxes;
   end;

procedure TfmMain.imgGraphClick(Sender: TObject);
   var
       fAllDataPresent : Boolean;
       sglMu, sglLambda : single; //projection on e1 and e2 axis

   begin
     //select click
     if btnSetAxes.enabled = true then       // happy datagrabbing stage
     begin
       fAllDataPresent := TRUE;
       if ptE1.x = -100 then fAllDataPresent := FALSE;
       if ptE2.x = -100 then fAllDataPresent := FALSE;
                         {maybe expand with axes coordinates}
       if fAllDataPresent then
       begin
         if lstGrabbedData.lines[0] = '(no data)' then
         begin
           lstGrabbedData.Clear;
           if fWriteFileNameInData then lstGrabbedData.lines.Add(dlgOpenImage.FileName);
         end;
         if lstGrabbedData.lines[0] = '(Define axes first)' then
         begin
           lstGrabbedData.Clear;
           if fWriteFileNameInData then lstGrabbedData.lines.Add(dlgOpenImage.FileName);
         end;
         //if lstGrabbedData. = '' then
         //  if fWriteFileNameInData then lstGrabbedData.lines[0]:= dlgOpenImage.FileName;
         lstGrabbedData.lines.add( FormatFloat(StrFormatDigitsX, sglGrabbedXValue) + #9 +
                                   FormatFloat(StrFormatDigitsY ,sglGrabbedYValue));
       end;
       if not fAllDataPresent then
       begin
         lstGrabbedData.Clear;
         //lstGrabbedData.lines.Add('(Define axes first)');
       end;
     end;
   end;

procedure TfmMain.imgGraphMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ptTemp.X := X;
  ptTemp.Y := Y;
  if btnSetAxes.checked = false then
  begin
    fDrawState := TRUE;
    imgGraph.Canvas.Pen.Color := clBlue;
    //needs to set the drawing to color if it is B&W
    if ptE1.x = -100 then           {draw the first axis}
    begin
      imgGraph.Canvas.MoveTo(X*imgGraph.Picture.Graphic.width div imgGraph.Width ,
                             Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);

      ptOrigin := Point(X *imgGraph.Picture.Graphic.width div imgGraph.Width ,
                        Y *imgGraph.Picture.Graphic.Height div imgGraph.Height);
      ptMove := ptOrigin;
      //fDrawState := TRUE;
      ptE2.x := -100
    end
    else
    begin
      if ptE2.x = -100 then     {draw the second axis}
      begin
        imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.y);
        imgGraph.Canvas.LineTo(X*imgGraph.Picture.Graphic.width div imgGraph.Width ,
                             Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);
      end
      else
      begin                   {reset all}
        //undraw axes
        imgGraph.Canvas.Pen.Mode := pmNotXor;
        imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
        imgGraph.Canvas.LineTo(ptE1.X, ptE1.Y);
        imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
        imgGraph.Canvas.LineTo(ptE2.X, ptE2.Y);


        //imgGraph.Canvas.TextOut(ptE2.x-10, ptE2.y+10, 'y');

        imgGraph.Canvas.Pen.Mode := pmCopy;

        //restart
        imgGraph.Canvas.MoveTo(X*imgGraph.Picture.Graphic.width div imgGraph.Width ,
                             Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);

        ptOrigin := Point(X*imgGraph.Picture.Graphic.width div imgGraph.Width ,
                        Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);
        ptMove := ptOrigin;
        ptE2.x := -100;
        ptE1.x := -100;
      end;
    end;
  end;
end;

procedure TfmMain.imgGraphMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
   var
         sglMu, sglLambda : single;
   begin
     edPixelX.text := IntToStr(X);
     edPixelY.text := IntToStr(imgGraph.height - Y);
     if btnSetAxes.checked = false then
     begin
       if fDrawState = TRUE then
       begin
         if ptE1.x = -100 then           {define first axis end point}
         begin
           imgGraph.Canvas.Pen.Mode := pmNotXor;
           imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
           imgGraph.Canvas.LineTo(ptMove.X, ptMove.Y);
           imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
           imgGraph.Canvas.LineTo(X*imgGraph.Picture.Graphic.width div imgGraph.Width,
                              Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);
         end
         else
         if ptE2.x = -100 then     {draw the second axis}
         begin
           imgGraph.Canvas.Pen.Mode := pmNotXor;
           imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
           imgGraph.Canvas.LineTo(ptMove.X, ptMove.Y);
           imgGraph.Canvas.MoveTo(ptOrigin.X, ptOrigin.Y);
           imgGraph.Canvas.LineTo(X*imgGraph.Picture.Graphic.width div imgGraph.Width,
                                Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);
         end;

       end;
       ptMove := Point(X*imgGraph.Picture.Graphic.width div imgGraph.Width,
                       Y*imgGraph.Picture.Graphic.Height div imgGraph.Height);
       imgGraph.Canvas.Pen.Mode := pmCopy;
     end;
     if btnSetAxes.Checked then
     begin
       //real maths, needs to be removed from mouseClick Code once ready
       // n° 1: scale location as a fraction of the width and heigth
       ptFrClickedX  := (X * imgGraph.Picture.Graphic.width div imgGraph.Width
                           - ptOrigin.X)  / imgGraph.Width;
       ptFrClickedY  := (Y *imgGraph.Picture.Graphic.Height div imgGraph.Height
                           - ptOrigin.Y )  / imgGraph.Height;
       // process these two values of the selected point
       try
         sglMu    :=  (ptFrClickedX-(ptFrE2X/ptFrE2Y)*ptFrClickedY)/
                      (ptFrE1X-(ptFrE2X/ptFrE2Y)*ptFrE1Y);
        except sglMu := 0;
       end;

       {((ptFrClickedX * ptFrE2Y)-(ptFrE2X * ptFrClickedY))/
                   ((ptFrE1X*ptFrE2Y)-(ptFrE2X*ptFrE2Y));  wrong!}
       try
         sglLambda:=  (ptFrClickedY-(ptFrE1Y/ptFrE1X)*ptFrClickedX)/
                      (ptFrE2Y-(ptFrE1Y/ptFrE1X)*ptFrE2X);
        except sglLambda := 0;
       end;
       {(-(ptFrClickedY * ptFrE1X)+(ptFrE1Y * ptFrClickedX))/
                   (ptFrE2Y*(-ptFrE1X+ptFrE1Y));  wrong!}

       if not chkXLog.checked then
       sglGrabbedXValue :=  sglXAxisMin+sglMu*(sglXAxisMax-sglXAxisMin)
       else
       sglGrabbedXValue :=  exp(sglMu*(ln(sglXAxisMax)-ln(sglXAxisMin))+ln(sglXAxisMin));
       if not chkYLog.checked then
       sglGrabbedYValue :=  sglYAxisMin+sglLambda*(sglYAxisMax-sglYAxisMin)
       else
       sglGrabbedYValue :=  exp(sglLambda*(ln(sglYAxisMax)-ln(sglYAxisMin))+ln(sglYAxisMin));
       edCoordinateX.text := FloatToStr(sglGrabbedXValue);
       edCoordinateY.text := FloatToStr(sglGrabbedYValue);

     end;
   end;

procedure TfmMain.imgGraphMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
   begin
     if btnSetAxes.checked = false then  //the "set axes bit"
     begin
       if ptE1.x = -100 then           {define first axis end point}
       begin
         ptE1 := ptMove;
         //imgGraph.Canvas.TextOut(ptE1.x-10, ptE1.y+10, 'x');
       end
       else
       begin
         if ptE2.x = -100 then     {draw the second axis}
         begin
           ptE2 := ptMove;
           //imgGraph.Canvas.TextOut(ptE2.x-10, ptE2.y+10, 'y');
           FormResize(Sender);
           fBothAxesDefined := truE;
         end
         else
         begin                   {reset all}
           //clear x and y text
         end;
       end;
       fDrawState := FALSE;
     end;
   end;


procedure TfmMain.btnOpenImageClick(Sender: TObject);
   var
   strCurrentFile : string;
begin
  if dlgOpenImage.execute then
  begin
    //
    //reset all coordinates
    // note:the original -1 causes problems, due to canvas size sometimes including -1
    // sloppy approach, now changed to -100, awaiting an appropriate solution.
    ptE2.x := -100;
    ptE1.x := -100;
    ptOrigin.x := -100;
    ptOrigin.y := -100;
    //
    strCurrentFile := dlgOpenImage.FileName;
    imgGraph.Picture.LoadFromFile(strCurrentFile);
    imgGraph.Picture.Bitmap.Monochrome := FALSE;
    fmMain.caption := 'Data Grabber: '+ strCurrentFile;
    //define the line width as .. pixels of the picture
    imgGraph.Canvas.Pen.Width := iPenWidthFactor* imgGraph.Width  div imgGraph.Picture.Graphic.width;
    if imgGraph.Width > imgGraph.Picture.Graphic.width then imgGraph.Canvas.Pen.Width := 1;
  end;
end;

procedure TfmMain.MenuSaveClick(Sender: TObject);
   var
     strOneLine, strTextFileName : string;
     txtSaveData : textfile;
   begin
     if SaveDialog1.execute then
     begin
       strTextFileName:=SaveDialog1.FileName;
       try
         AssignFile(txtSaveData, strTextFileName);
        except
         AssignFile(txtSaveData, 'rescue.txt');
       end;
       try
         Append(txtSaveData);
        except
         Rewrite(txtSaveData);
       end;
       //for i := 1 to lstGrabbedData.lines.
       WriteLn(txtSaveData, lstGrabbedData.text);
       CloseFile(txtSaveData);
     end;
   end;

procedure TfmMain.MenuItem6Click(Sender: TObject);
begin
  close;
end;

procedure TfmMain.MenuItem7Click(Sender: TObject);
 var gAppPath, gAppName : string;
begin
  gAppPath := ParamStr(0);
  gAppName := ApplicationName;
  gAppPath:=LeftStr(gAppPath,(length(gAppPath)-length(gAppName)-4));      // -4 is to compensate for the ".exe"
  OpenURL('file:///'+gAppPath+'graphgrabber.html');
end;

procedure TfmMain.mnuAboutClick(Sender: TObject);
   begin
     //tabSetOrGrab.TabIndex := 1;
     //tabSetOrGrabChange(Sender);
     lstGrabbedData.lines.Add('');
     lstGrabbedData.lines.Add('GraphGrabber,');
     lstGrabbedData.lines.Add('A simple program');
     lstGrabbedData.lines.Add('to digitise the ');
     lstGrabbedData.lines.Add('coordinates of an');
     lstGrabbedData.lines.Add('image.');
     lstGrabbedData.lines.Add('');
     lstGrabbedData.lines.Add('Written and © by');
     lstGrabbedData.lines.Add('Pieter van der Wolk');
     lstGrabbedData.lines.Add('pwolk@dds.nl');
     lstGrabbedData.lines.Add(strVersion);
     lstGrabbedData.lines.Add('');
   end;

procedure TfmMain.ProcessIniFile(Sender: TObject);
var
  txtIniFile : textfile;
  iEqualsPos : integer;
  strLine    : string;
  strDenom, strSpecification : string;

begin

  try //open ini file
    AssignFile(txtIniFile, strIniFileName);
    Reset(txtIniFile);
   except  // write new ini file
    Rewrite(txtIniFile);
    WriteLn(txtIniFile, strIni1);  WriteLn(txtIniFile, strIni2);
    WriteLn(txtIniFile, strIni3);  WriteLn(txtIniFile, strIni4);
    WriteLn(txtIniFile, strIni5);  WriteLn(txtIniFile, strIni6);
    WriteLn(txtIniFile, strIni7);  WriteLn(txtIniFile, strIni5);
    WriteLn(txtIniFile, strIni8);
    WriteLn(txtIniFile, strIni9);  WriteLn(txtIniFile, strIni10);
    WriteLn(txtIniFile, strIni11); WriteLn(txtIniFile, strIni12);
    WriteLn(txtIniFile, strIni13); WriteLn(txtIniFile, strIni14);
    WriteLn(txtIniFile, strIni15); WriteLn(txtIniFile, strIni5);
    WriteLn(txtIniFile, strIni16);
    WriteLn(txtIniFile, strIni17);
    WriteLn(txtIniFile, strIni18);

    CloseFile(txtIniFile);
    AssignFile(txtIniFile, strIniFileName);
    Reset(txtIniFile);
  end;
  while not EOF(txtIniFile)do
  begin
    Readln(txtIniFile, strLine);
    try
      iEqualsPos       := pos('=',strLine);
      strDenom         := copy(StrLine,1 ,(iEqualsPos-1));
      strDenom         := Trim(LowerCase(strDenom));
      strSpecification := copy(StrLine,(iEqualsPos+1), StrLen(PChar(StrLine)));
      strSpecification := Trim(LowerCase(strSpecification));
      if strDenom = 'opendirectory' then  dlgOpenImage.initialDir := strSpecification;
      if strDenom = 'savedirectory' then  SaveDialog1.initialDir := strSpecification;
      if strDenom = 'formatxdata' then StrFormatDigitsX := strSpecification;
      if strDenom = 'formatydata' then StrFormatDigitsY := strSpecification;
      if strDenom = 'defaultxorigin' then strDefaultX1Origin := strSpecification;
      if strDenom = 'defaultxmax' then strDefaultX1XAxis := strSpecification;
      if strDenom = 'defaultyorigin' then strDefaultY1Origin := strSpecification;
      if strDenom = 'defaultymax' then strDefaultY1YAxis := strSpecification;
      if strDenom = 'defaultxoriginlog' then strDefaultX1OriginLog := strSpecification;
      if strDenom = 'defaultxmaxlog' then strDefaultX1XAxisLog := strSpecification;
      if strDenom = 'defaultyoriginlog' then strDefaultY1OriginLog := strSpecification;
      if strDenom = 'defaultymaxlog' then strDefaultY1YAxisLog := strSpecification;
      if strDenom = 'xaxisislog' then
         if ((strSpecification = 'true') or (strSpecification = 'yes')) then
            chkXlog.Checked := TRUE
            else chkXlog.Checked := FALSE;
      if strDenom = 'yaxisislog' then
         if ((strSpecification = 'true') or (strSpecification = 'yes')) then
            chkYlog.Checked := TRUE
            else chkYlog.Checked := FALSE;
      if strDenom = 'writefilenameindata' then
         if ((strSpecification = 'true') or (strSpecification = 'yes')) then
            fWriteFileNameInData := TRUE
            else fWriteFileNameInData := FALSE;
     except
    end;
  end;

  CloseFile(txtIniFile);
end;

end.

