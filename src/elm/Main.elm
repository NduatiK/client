module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Doc.UI as UI
import Html
import Json.Decode as Dec exposing (Decoder, Value)
import Outgoing exposing (Msg(..), send)
import Page.App
import Page.Copy
import Page.Doc
import Page.DocNew
import Page.ForgotPassword
import Page.Import
import Page.Login
import Page.Message
import Page.NotFound
import Page.ResetPassword
import Page.Signup
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



-- MODEL


type Model
    = Redirect Session
    | TestAppPage Page.App.Model
    | NotFound Session
    | PaymentSuccess Session
    | Signup Page.Signup.Model
    | Login Page.Login.Model
    | ForgotPassword Page.ForgotPassword.Model
    | ResetPassword Page.ResetPassword.Model
    | Copy Page.Copy.Model
    | Import Page.Import.Model
    | DocNew Session
    | Doc Page.Doc.Model


init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init json url navKey =
    let
        user =
            Session.decode navKey json
    in
    case ( Session.loggedIn user, Route.fromUrl url ) of
        ( True, route_ ) ->
            changeRouteTo route_ (Redirect user)

        ( False, Just Route.Login ) ->
            changeRouteTo (Just Route.Login) (Redirect user)

        ( False, Just (Route.ForgotPassword token) ) ->
            changeRouteTo (Just (Route.ForgotPassword token)) (Redirect user)

        ( False, Just (Route.ResetPassword token) ) ->
            changeRouteTo (Just (Route.ResetPassword token)) (Redirect user)

        ( False, _ ) ->
            changeRouteTo (Just Route.Signup) (Redirect user)


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        user =
            toUser model
    in
    if Session.loggedIn user then
        case maybeRoute of
            Just Route.Root ->
                Page.App.init user Nothing |> updateWith TestAppPage GotAppMsg

            Just Route.TestApp ->
                Page.App.init user Nothing |> updateWith TestAppPage GotAppMsg

            Just Route.Signup ->
                Page.Signup.init user |> updateWith Signup GotSignupMsg

            Just Route.Login ->
                Page.App.init user Nothing |> updateWith TestAppPage GotAppMsg

            Just (Route.ForgotPassword email_) ->
                Page.ForgotPassword.init user email_
                    |> updateWith ForgotPassword GotForgotPasswordMsg

            Just (Route.ResetPassword token) ->
                Page.ResetPassword.init user token
                    |> updateWith ResetPassword GotResetPasswordMsg

            Just Route.DocNew ->
                Page.DocNew.init user |> updateWith DocNew GotDocNewMsg

            Just (Route.DocUntitled dbName) ->
                let
                    isNew =
                        case model of
                            DocNew _ ->
                                True

                            _ ->
                                False
                in
                Page.Doc.init user dbName isNew |> updateWith Doc GotDocMsg

            Just (Route.Doc dbName _) ->
                Page.Doc.init user dbName False |> updateWith Doc GotDocMsg

            Just (Route.Copy dbName) ->
                Page.Copy.init user dbName |> updateWith Copy GotCopyMsg

            Just (Route.Import template) ->
                Page.Import.init user template
                    |> updateWith Import GotImportMsg

            Just (Route.Upgrade isOk) ->
                if isOk then
                    ( PaymentSuccess user, Cmd.none )

                else
                    ( Redirect user, Cmd.none )

            Nothing ->
                ( NotFound user, Cmd.none )

    else
        let
            ( signupModel, signupCmds ) =
                Page.Signup.init user
                    |> updateWith Signup GotSignupMsg

            ( loginModel, loginCmds ) =
                Page.Login.init user
                    |> updateWith Login GotLoginMsg
        in
        case maybeRoute of
            Just Route.Signup ->
                ( signupModel, Cmd.batch [ signupCmds, Route.replaceUrl (Session.navKey user) Route.Signup ] )

            Just Route.Login ->
                ( loginModel, loginCmds )

            Just (Route.ForgotPassword email_) ->
                Page.ForgotPassword.init user email_
                    |> updateWith ForgotPassword GotForgotPasswordMsg

            Just (Route.ResetPassword token) ->
                Page.ResetPassword.init user token
                    |> updateWith ResetPassword GotResetPasswordMsg

            _ ->
                ( loginModel, Cmd.batch [ loginCmds, Route.replaceUrl (Session.navKey user) Route.Login ] )


toUser : Model -> Session
toUser page =
    case page of
        Redirect user ->
            user

        TestAppPage testAppPage ->
            Page.App.toUser testAppPage

        NotFound user ->
            user

        PaymentSuccess user ->
            user

        Signup signup ->
            Page.Signup.toUser signup

        Login login ->
            Page.Login.toUser login

        ForgotPassword forgot ->
            Page.ForgotPassword.toUser forgot

        ResetPassword reset ->
            Page.ResetPassword.toUser reset

        Copy copy ->
            Page.Copy.toUser copy

        Import user ->
            user

        DocNew user ->
            user

        Doc doc ->
            Page.Doc.toUser doc



-- UPDATE


type Msg
    = NoOp
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | SettingsChanged Dec.Value
    | GotAppMsg Page.App.Msg
    | GotSignupMsg Page.Signup.Msg
    | GotLoginMsg Page.Login.Msg
    | GotForgotPasswordMsg Page.ForgotPassword.Msg
    | GotResetPasswordMsg Page.ResetPassword.Msg
    | GotCopyMsg Page.Copy.Msg
    | GotImportMsg Page.Import.Msg
    | GotDocNewMsg Page.DocNew.Msg
    | GotDocMsg Page.Doc.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, Signup _ ) ->
            case Route.fromUrl url of
                Just Route.Signup ->
                    ( model, Cmd.none )

                otherRoute ->
                    changeRouteTo otherRoute model

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, Doc docModel ) ->
            case urlRequest of
                Browser.Internal url ->
                    if docModel.dirty then
                        let
                            saveShortcut =
                                if Session.isMac docModel.session then
                                    "⌘+enter"

                                else
                                    "Ctrl+Enter"
                        in
                        ( model, send <| Alert ("You have unsaved changes!\n" ++ saveShortcut ++ " to save.") )

                    else
                        ( model, Nav.pushUrl (Session.navKey (toUser model)) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (Session.navKey (toUser model)) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( SettingsChanged json, PaymentSuccess session ) ->
            ( PaymentSuccess (Session.sync json session), Cmd.none )

        ( GotAppMsg appMsg, TestAppPage appModel ) ->
            Page.App.update appMsg appModel |> updateWith TestAppPage GotAppMsg

        ( GotSignupMsg signupMsg, Signup signupModel ) ->
            Page.Signup.update signupMsg signupModel
                |> updateWith Signup GotSignupMsg

        ( GotLoginMsg loginMsg, Login loginModel ) ->
            Page.Login.update loginMsg loginModel
                |> updateWith Login GotLoginMsg

        ( GotForgotPasswordMsg forgotPassMsg, ForgotPassword forgotPassModel ) ->
            Page.ForgotPassword.update forgotPassMsg forgotPassModel
                |> updateWith ForgotPassword GotForgotPasswordMsg

        ( GotResetPasswordMsg resetPassMsg, ResetPassword resetPassModel ) ->
            Page.ResetPassword.update resetPassMsg resetPassModel
                |> updateWith ResetPassword GotResetPasswordMsg

        ( GotCopyMsg copyMsg, Copy copyModel ) ->
            Page.Copy.update copyMsg copyModel
                |> updateWith Copy GotCopyMsg

        ( GotImportMsg homeMsg, Import homeModel ) ->
            Page.Import.update homeMsg homeModel
                |> updateWith Import GotImportMsg

        ( GotDocNewMsg docNewMsg, DocNew docNewModel ) ->
            Page.DocNew.update docNewMsg docNewModel
                |> updateWith DocNew GotDocNewMsg

        ( GotDocMsg docMsg, Doc docModel ) ->
            Page.Doc.update docMsg docModel
                |> updateWith Doc GotDocMsg

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


withCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withCmd newCmd ( model, cmd ) =
    ( model, Cmd.batch [ newCmd, cmd ] )



-- VIEW


view : Model -> Document Msg
view model =
    case model of
        Redirect _ ->
            { title = "Gingko Writer - Loading...", body = [ UI.viewLoadingSpinner False ] }

        TestAppPage app ->
            { title = "Gingko Writer - Test Page", body = [ Html.map GotAppMsg (Page.App.view app) ] }

        NotFound _ ->
            Page.NotFound.view

        PaymentSuccess _ ->
            Page.Message.viewSuccess

        Signup signup ->
            { title = "Gingko Writer - Signup", body = [ Html.map GotSignupMsg (Page.Signup.view signup) ] }

        Login login ->
            { title = "Gingko Writer - Login", body = [ Html.map GotLoginMsg (Page.Login.view login) ] }

        ForgotPassword forgotPass ->
            { title = "Gingko - Forgot Password", body = [ Html.map GotForgotPasswordMsg (Page.ForgotPassword.view forgotPass) ] }

        ResetPassword resetPass ->
            { title = "Gingko - Reset Password", body = [ Html.map GotResetPasswordMsg (Page.ResetPassword.view resetPass) ] }

        Copy copyModel ->
            { title = "Duplicating...", body = [ UI.viewLoadingSpinner (Session.fileMenuOpen copyModel.session) ] }

        Import importModel ->
            { title = "Importing...", body = [ UI.viewLoadingSpinner (Session.fileMenuOpen importModel) ] }

        DocNew _ ->
            { title = "Gingko Writer - New", body = [ Html.div [] [ Html.text "LOADING..." ] ] }

        Doc doc ->
            { title = Page.Doc.getTitle doc ++ " - Gingko Writer", body = [ Html.map GotDocMsg (Page.Doc.view doc) ] }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Redirect _ ->
            Sub.none

        TestAppPage appModel ->
            Sub.map GotAppMsg (Page.App.subscriptions appModel)

        NotFound _ ->
            Sub.none

        PaymentSuccess _ ->
            Session.userSettingsChange SettingsChanged

        Signup pageModel ->
            Sub.map GotSignupMsg (Page.Signup.subscriptions pageModel)

        ForgotPassword pageModel ->
            Sub.map GotForgotPasswordMsg (Page.ForgotPassword.subscriptions pageModel)

        ResetPassword pageModel ->
            Sub.map GotResetPasswordMsg (Page.ResetPassword.subscriptions pageModel)

        Login pageModel ->
            Sub.map GotLoginMsg (Page.Login.subscriptions pageModel)

        Copy pageModel ->
            Sub.map GotCopyMsg (Page.Copy.subscriptions pageModel)

        Import pageModel ->
            Sub.map GotImportMsg (Page.Import.subscriptions pageModel)

        DocNew _ ->
            Sub.none

        Doc pageModel ->
            Sub.map GotDocMsg (Page.Doc.subscriptions pageModel)



-- MAIN


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }
