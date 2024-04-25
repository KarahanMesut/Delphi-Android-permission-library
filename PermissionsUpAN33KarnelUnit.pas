//Prepared by Mesut Karahan

unit PermissionsUpAn33KarnelUnit;

interface
uses System.Permissions, FMX.MediaLibrary.Actions,System.Types,System.SysUtils
,System.UITypes,Fmx.Dialogs,Fmx.Platform,System.Notification,System.PushNotification,System.Classes
,Fmx.Memo,FMX.Memo.Types, FMX.Controls.Presentation,FMX.ScrollBox,Fmx.Types ,
{$IFDEf ANDROID}
   FMX.PushNotification.Android,
  {$ENDIF}
   {$IFDEf IOS}
   FMX.PushNotification.FCM.IOS,
  {$ENDIF}
  FMX.ListBox;

type
    TCallbackProc = procedure(Sender: TObject) of Object;

    TQBSPermissions = class
    private
        CurrentRequest : string;
        pCamera, pMediaImages,pMediaAudios, pMediaVideos,pWriteStorage : string; // Camera / Library
        pFineLocation, pCoarseLocation : string; // GPS
        pPhoneState : string; // Phone State
        FPushService:TPushService;
        FPushServiceConnection:TPushServiceConnection;
    procedure OnServiceConnectionChange(Sender: TObject;
      PushChanges: TPushService.TChanges);
    procedure OnServiceConnectionReceiveNotification(Sender: TObject;
      const ServiceNotification: TPushServiceNotification);
       procedure RegisterToken(User_Code: Integer; Push_Token: String);

             {$IFDEF ANDROID}
  // PermissionCamera,PermissionReadStorage,PermissionWriteStorage:string;

    procedure DisplayMessageCamera(const APermissions: TClassicStringDynArray; const APostProc: TProc);
    procedure DisplayMessageLibrary(const APermissions: TClassicStringDynArray; const APostProc: TProc);
    procedure DisplayMessageLocation(const APermissions: TClassicStringDynArray; const APostProc: TProc);
    procedure DisplayMessageAudio(const APermissions: TClassicStringDynArray; const APostProc: TProc);
    procedure DisplayMessagePhone(const APermissions: TClassicStringDynArray; const APostProc: TProc);

      {$ENDIF}
        procedure PermissionRequestResult(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
        procedure Timer1Timer(Sender: TObject);
    public
        MyCallBack, MyCallBackError : TCallbackProc;
        MyCameraAction : TTakePhotoFromCameraAction;
        MyLibraryAction : TTakePhotoFromLibraryAction;
        function IsInternetConnected: Boolean;
        constructor Create;
        function VerifyCameraAccess(): boolean;
         function VerifyLibraryAccess: boolean;
         function VerifyLocationAccess: boolean;
         function VerifyAudiosAccess: boolean;
         function VerifyWritingAccess: boolean;
         function VerifyPhoneAccess: boolean;
         function VerifyVideosAccess: boolean;
           function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
        procedure Camera(ActionPhoto: TTakePhotoFromCameraAction;
                          ACallBackError: TCallbackProc = nil);
        procedure PhotoLibrary(ActionLibrary: TTakePhotoFromLibraryAction;
                        ACallBackError: TCallbackProc = nil);
        procedure Location(ACallBack: TCallbackProc = nil;
                        ACallBackError: TCallbackProc = nil);
        procedure PhoneState(ACallBack: TCallbackProc = nil;
                        ACallBackError: TCallbackProc = nil);
        procedure ReadWriteFiles(ACallBack: TCallbackProc = nil;
                                 ACallBackError: TCallbackProc = nil);
        procedure Audio(ACallBack: TCallbackProc = nil;
                                 ACallBackError: TCallbackProc = nil);
        procedure Video(ACallBack: TCallbackProc = nil;
                                 ACallBackError: TCallbackProc = nil);
    published

end;


implementation
Uses
SplashScreenUnit,LogonUnit,
{$IFDEF ANDROID}
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Support,
  Androidapi.JNIBridge,
  FMX.Helpers.Android,
  Androidapi.JNI.App,

{$ENDIF}
FMX.DialogService;
var
  Timer1: TTimer;
procedure TQBSPermissions.Timer1Timer(Sender: TObject);
 var
    AppEvent : IFMXApplicationEventService;
      Notifications : TArray<TPushServiceNotification>;
    x : integer;
begin
  Timer1.Enabled:=False;
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEvent)) then
        AppEvent.SetApplicationEventHandler(AppEventProc);

    {$IFDEF MSWINDOWS}
    showmessage('Bildirim Ayarlarý Windows tarafýndan desteklenmiyor');
    {$ELSE}

    FPushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.FCM);
    FPushServiceConnection := TPushServiceConnection.Create(FPushService);

    FPushServiceConnection.OnChange := OnServiceConnectionChange;
    FPushServiceConnection.OnReceiveNotification := OnServiceConnectionReceiveNotification;

    FPushServiceConnection.Active := True;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    Memo1.Lines.Add('Bildirim Windowsta Desteklenmez');
    {$ELSE}
    Notifications := FPushService.StartupNotifications;

    if Length(Notifications) > 0 then
    begin
        for x := 0 to Notifications[0].DataObject.Count - 1 do
            SplashScreenForm.Memo1.lines.Add(Notifications[0].DataObject.Pairs[x].JsonString.Value + ' = ' +
                             Notifications[0].DataObject.Pairs[x].JsonValue.Value);

    end;
    {$ENDIF}






end;
 procedure TQBSPermissions.RegisterToken(User_Code:Integer;Push_Token:String);
 var
i,j:Integer;
Parametre:TStringList;
donen:String;
Begin
 //TOKEN_ID:=Push_Token;
  try
  try


 


  except on E: Exception do
  end;
  finally

  end;


End;
procedure TQBSPermissions.OnServiceConnectionChange(Sender: TObject;
  PushChanges: TPushService.TChanges);
var
    token : string;
begin
    if TPushService.TChange.Status in PushChanges then
    begin
        if FPushService.Status = TPushService.TStatus.Started then
            SplashScreenForm.Memo2.Lines.Add('Bildirim Ýþlemleri Baþarýlý Bir þekilde Baþlatýldý')

        else
        if FPushService.Status = TPushService.TStatus.StartupError then
        begin
            FPushServiceConnection.Active := False;

            SplashScreenForm.Memo2.Lines.Add('Bildirim Ýþlemleri  Baþlatýlamadý');
            SplashScreenForm.Memo2.Lines.Add(FPushService.StartupError);
        end;
    end;

     if TPushService.TChange.DeviceToken in PushChanges then
    begin
        token := FPushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];

        SplashScreenForm.Memo2.Lines.Add('Device token received');
        SplashScreenForm.Memo2.Lines.Add('Token: ' + token);
        RegisterToken(1, token);
        if not SplashScreenForm.DataControl(token) then
        Begin
        SplashScreenForm.Hide;
        LogonForm.Show;
        End;



  


    end;
end;
procedure TQBSPermissions.OnServiceConnectionReceiveNotification(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
begin
    SplashScreenForm.Memo2.Lines.Add('----------------------------------------');
    SplashScreenForm.Memo2.Lines.Add('Push notification received');
    SplashScreenForm.Memo2.Lines.Add('DataKey: ' + ServiceNotification.DataKey);
    SplashScreenForm.Memo2.Lines.Add('Json: ' + ServiceNotification.Json.ToString);
    SplashScreenForm.Memo2.Lines.Add('DataObject: ' + ServiceNotification.DataObject.ToString);
end;

function TQBSPermissions.AppEventProc(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
    if (AAppEvent = TApplicationEvent.BecameActive) then
    Begin
    SplashScreenForm.NotificationCenter1.CancelAll;
    End;


end;

{$IFDEF ANDROID}
procedure TQBSPermissions.DisplayMessageCamera (const APermissions: TClassicStringDynArray; const APostProc: TProc);
Begin
TDialogService.ShowMessage('Bu Ýþlemi Yapabilmeniz Ýçin Uygulamanýn  Kamera Kullanýmýna Ýzin Verilmesi Gerekiyor.',
procedure (const Result:TModalResult)
Begin
 APostProc;
End);
End;
procedure TQBSPermissions.DisplayMessageLibrary (const APermissions: TClassicStringDynArray; const APostProc: TProc);
Begin
TDialogService.ShowMessage('Bu Ýþlemi Yapabilmeniz Ýçin  Uygulamanýn Cihaz Kütüphanesine Eriþimine Ýzin Gerekiyor.',
procedure (const Result:TModalResult)
Begin
 APostProc;
End);
End;
procedure TQBSPermissions.DisplayMessageLocation (const APermissions: TClassicStringDynArray; const APostProc: TProc);
Begin
TDialogService.ShowMessage('Bu Ýþlemi Yapabilmeniz Ýçin Uygulamanýn Cihazýn Konum Bilgilerine Eriþmesine Ýzin Verilmesi gerekiyor',
procedure (const Result:TModalResult)
Begin
 APostProc;
End);
End;
procedure TQBSPermissions.DisplayMessageAudio (const APermissions: TClassicStringDynArray; const APostProc: TProc);
Begin
TDialogService.ShowMessage('Bu Ýþlemi Yapabilmeniz Ýçin Uygulamanýn Cihazýn Müzik Ve Ses Bilgilerine Eriþmesine Ýzin Verilmesi gerekiyor',
procedure (const Result:TModalResult)
Begin
 APostProc;
End);
End;
procedure TQBSPermissions.DisplayMessagePhone (const APermissions: TClassicStringDynArray; const APostProc: TProc);
Begin
TDialogService.ShowMessage('Bu Ýþlemi Yapabilmeniz Ýçin Uygulamanýn Cihazýn Telefon Bilgilerine Eriþmesine Ýzin Verilmesi gerekiyor',
procedure (const Result:TModalResult)
Begin
 APostProc;
End);
End;
{$ENDIF}
function TQBSPermissions.VerifyCameraAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pCamera]);
    {$ENDIF}
end;
function TQBSPermissions.VerifyLibraryAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pMediaImages]);

    {$ENDIF}
end;
function TQBSPermissions.VerifyAudiosAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pMediaAudios]);

    {$ENDIF}
end;
function TQBSPermissions.VerifyVideosAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pMediaVideos]);

    {$ENDIF}
end;
function TQBSPermissions.VerifyLocationAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pCoarseLocation, pFineLocation]);

    {$ENDIF}
end;
function TQBSPermissions.VerifyPhoneAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pPhoneState]);

    {$ENDIF}
end;
function TQBSPermissions.VerifyWritingAccess(): boolean;
begin
    Result := false;

    {$IFDEF ANDROID}
    Result := PermissionsService.IsEveryPermissionGranted([pWriteStorage]);

    {$ENDIF}
end;
constructor TQBSPermissions.Create();
begin

  {$IFDEF ANDROID}
    pCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
    pMediaImages := JStringToString(TJManifest_permission.JavaClass.READ_MEDIA_IMAGES);
    pMediaAudios:= JStringToString(TJManifest_permission.JavaClass.READ_MEDIA_AUDIO);
    pMediaVideos:= JStringToString(TJManifest_permission.JavaClass.READ_MEDIA_VIDEO);
    pWriteStorage := JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);
    pCoarseLocation := JStringToString(TJManifest_permission.JavaClass.ACCESS_COARSE_LOCATION);
    pFineLocation := JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION);
    pPhoneState := JStringToString(TJManifest_permission.JavaClass.READ_PHONE_STATE);
    {$ENDIF}
   Timer1 := TTimer.Create(nil);
   Timer1.Enabled := False;
   Timer1.Interval := 4000;
   Timer1.OnTimer := Timer1Timer;
   Timer1.Enabled := True;

   
end;
procedure TQBSPermissions.PermissionRequestResult (const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
var
    ret : boolean;
    perm: TPermissionStatus;
    Amessage:String;
begin
    ret := false;

     for perm in AGrantResults do
        if perm <> TPermissionStatus.Granted then
        begin
          if CurrentRequest = 'CAMERA' then
          begin
           Amessage:='Kamerayý çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'LIBRARY' then
          begin
           Amessage:='Kütüphaneyi çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'LOCATION' then
          begin
           Amessage:='Konum servislerini çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'READ_PHONE_STATE' then
          begin
           Amessage:='Telefon servislerini çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'AUDIO' then
          begin
           Amessage:='Ses servislerini çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'VIDEO' then
          begin
            Amessage:='Kütüphaneyi çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end Else if CurrentRequest = 'READ_WRITE_FILES' then
          begin
            Amessage:='Yazma servislerini çalýþtýrma izniniz bulunmuyor. Önce izin vermelisiniz';
          end;

          ShowMessage(Amessage);
          Exit;
        end Else
        Begin
        ret := true;
           if CurrentRequest = 'CAMERA' then
          begin
              if Assigned(MyCameraAction) then
              MyCameraAction.Execute;

          end Else if CurrentRequest = 'LIBRARY' then
          begin
            if Assigned(MyLibraryAction) then
            MyLibraryAction.Execute;
          end Else
          begin
          if Assigned(MyCallBack) then
          MyCallBack(Self);
          end;



        End;

    if NOT ret then
    begin
        if Assigned(MyCallBackError) then
            MyCallBackError(Self);
    end;
end;
procedure TQBSPermissions.Camera(ActionPhoto: TTakePhotoFromCameraAction;
                                ACallBackError: TCallbackProc = nil);
begin
    MyCameraAction := ActionPhoto;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'CAMERA';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pCamera],PermissionRequestResult,DisplayMessageCamera);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCameraAction) then
        MyCameraAction.Execute;
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Kamera Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;

procedure TQBSPermissions.ReadWriteFiles(ACallBack: TCallbackProc = nil;
                                  ACallBackError: TCallbackProc = nil);
begin
    MyCallBack := ACallBack;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'READ_WRITE_FILES';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pWriteStorage],
                                           PermissionRequestResult);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCameraAction) then
        MyCameraAction.Execute;
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    if Assigned(ACallBack) then
        ACallBack(Self);
    {$ENDIF}
end;

procedure TQBSPermissions.PhotoLibrary(ActionLibrary: TTakePhotoFromLibraryAction;
                                      ACallBackError: TCallbackProc = nil);
begin
    MyLibraryAction := ActionLibrary;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'LIBRARY';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pMediaImages],
                                           PermissionRequestResult,DisplayMessageLibrary);

    {$ENDIF}

    {$IFDEF IOS}
    ActionLibrary.Execute;
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Kütüphane Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;

procedure TQBSPermissions.Location(ACallBack: TCallbackProc = nil;
                                  ACallBackError: TCallbackProc = nil);
begin
    MyCallBack := ACallBack;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'LOCATION';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pCoarseLocation, pFineLocation],
                                           PermissionRequestResult,DisplayMessageLocation);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCallBack) then
        ACallBack(Self);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Lokasyon Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;

procedure TQBSPermissions.PhoneState(ACallBack: TCallbackProc = nil;
                                  ACallBackError: TCallbackProc = nil);
begin
    MyCallBack := ACallBack;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'READ_PHONE_STATE';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pPhoneState],
                                           PermissionRequestResult,DisplayMessagePhone);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCallBack) then
        ACallBack(Self);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Telefon Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;
procedure TQBSPermissions.Audio(ACallBack: TCallbackProc = nil;
                                  ACallBackError: TCallbackProc = nil);
begin
    MyCallBack := ACallBack;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'AUDIO';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pMediaAudios],
                                           PermissionRequestResult,DisplayMessageAudio);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCallBack) then
        ACallBack(Self);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Müzik Ses Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;
procedure TQBSPermissions.Video(ACallBack: TCallbackProc = nil;
                                  ACallBackError: TCallbackProc = nil);
begin
    MyCallBack := ACallBack;
    MyCallBackError := ACallBackError;
    CurrentRequest := 'VIDEO';

    {$IFDEF ANDROID}
    PermissionsService.RequestPermissions([pMediaVideos],
                                           PermissionRequestResult,DisplayMessageLibrary);
    {$ENDIF}

    {$IFDEF IOS}
    if Assigned(MyCallBack) then
        ACallBack(Self);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    TDialogService.ShowMessage('Kütüphane Servisleri Windows tarafýndan desteklenmiyor');
    {$ENDIF}
end;


function TQBSPermissions.IsInternetConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  NetworkInfo: JNetworkInfo;
begin
  ConnectivityManager := TJConnectivityManager.Wrap(TAndroidHelper.Context.getSystemService(TJContext.JavaClass.CONNECTIVITY_SERVICE));
  NetworkInfo := ConnectivityManager.getActiveNetworkInfo;

  Result := Assigned(NetworkInfo) and NetworkInfo.isConnected;
end;



end.
