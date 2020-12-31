module Translation exposing (Language(..), TranslationId(..), activeLanguages, dateFormat, langFromString, langToString, languageDecoder, languageName, timeDistInWords, tr)

import Json.Decode as Json exposing (..)
import Time
import Time.Distance as TimeDistance
import Time.Distance.I18n as I18n
import Time.Format exposing (format)
import Time.Format.Config.Config_en_us
import Time.Format.Config.Config_es_es
import Time.Format.Config.Config_fr_fr
import Time.Format.Config.Config_nl_nl
import Time.Format.Config.Config_sv_se


type TranslationId
    = Cancel
    | HomeBlank
    | HomeImportJSON
    | HomeJSONFrom
    | HomeImportLegacy
    | HomeLegacyFrom
    | RecentDocuments
    | LastUpdated
    | LastOpened
    | OpenOtherDocuments
    | DeleteDocument
    | RemoveFromList
    | NeverSaved
    | UnsavedChanges
    | SavedInternally
    | ChangesSaved
    | ChangesSynced
    | DatabaseError
    | LastSaved
    | LastEdit
    | KeyboardHelp
    | RestoreThisVersion
    | EnterKey
    | EnterAction
    | EditCardTitle
    | ArrowsAction
    | AddChildAction
    | SplitChildAction
    | InsertChildTitle
    | AddBelowAction
    | SplitBelowAction
    | MergeDownAction
    | InsertBelowTitle
    | AddAboveAction
    | SplitUpwardAction
    | MergeUpAction
    | InsertAboveTitle
    | ArrowKeys
    | MoveAction
    | Backspace
    | DeleteAction
    | DeleteCardTitle
    | FormattingGuide
    | ForBold
    | ForItalic
    | ToSaveChanges
    | SaveChangesTitle
    | EscKey
    | AreYouSureCancel
    | ToCancelChanges
    | PressToSearch
    | HeadingFont
    | ContentFont
    | EditingFont
    | WordCountSession Int
    | WordCountTotal Int
    | WordCountCard Int
    | WordCountSubtree Int
    | WordCountGroup Int
    | WordCountColumn Int


type Language
    = En
    | Zh_HANS
    | Zh_HANT
    | Es
    | Fr
    | Nl
    | Sv


languageName : Language -> String
languageName lang =
    case lang of
        En ->
            "English"

        Zh_HANS ->
            "简体中文"

        Zh_HANT ->
            "繁體中文"

        Es ->
            "Español"

        Fr ->
            "Français"

        Nl ->
            "Nederlands"

        Sv ->
            "Svenska"


activeLanguages : List ( Language, String )
activeLanguages =
    [ En, Zh_HANS, Zh_HANT, Es, Nl, Sv ] |> List.map (\l -> ( l, languageName l ))


tr : Language -> TranslationId -> String
tr lang trans =
    let
        pluralize n str =
            if n == 1 then
                str

            else
                str ++ "s"

        numberPlural n sing pl =
            if n == 1 then
                sing |> String.replace "%1" (String.fromInt n)

            else
                pl |> String.replace "%1" (String.fromInt n)

        translationSet =
            case trans of
                Cancel ->
                    { en = "Cancel"
                    , zh_hans = "%zh_hans:Cancel"
                    , zh_hant = "%zh_hant:Cancel"
                    , es = "%es:Cancel"
                    , fr = "%fr:Cancel"
                    , nl = "%nl:Cancel"
                    , sv = "%sv:Cancel"
                    }

                HomeBlank ->
                    { en = "Blank Tree"
                    , zh_hans = "%zh_hans:HomeBlank"
                    , zh_hant = "%zh_hant:HomeBlank"
                    , es = "%es:HomeBlank"
                    , fr = "%fr:HomeBlank"
                    , nl = "%nl:HomeBlank"
                    , sv = "%sv:HomeBlank"
                    }

                HomeImportJSON ->
                    { en = "Import JSON"
                    , zh_hans = "%zh_hans:HomeImportJSON"
                    , zh_hant = "%zh_hant:HomeImportJSON"
                    , es = "%es:HomeImportJSON"
                    , fr = "%fr:HomeImportJSON"
                    , nl = "%nl:HomeImportJSON"
                    , sv = "%sv:HomeImportJSON"
                    }

                HomeJSONFrom ->
                    { en = "From Desktop or Online"
                    , zh_hans = "%zh_hans:HomeJSONFrom"
                    , zh_hant = "%zh_hant:HomeJSONFrom"
                    , es = "%es:HomeJSONFrom"
                    , fr = "%fr:HomeJSONFrom"
                    , nl = "%nl:HomeJSONFrom"
                    , sv = "%sv:HomeJSONFrom"
                    }

                HomeImportLegacy ->
                    { en = "From Old Account"
                    , zh_hans = "%zh_hans:HomeImportLegacy"
                    , zh_hant = "%zh_hant:HomeImportLegacy"
                    , es = "%es:HomeImportLegacy"
                    , fr = "%fr:HomeImportLegacy"
                    , nl = "%nl:HomeImportLegacy"
                    , sv = "%sv:HomeImportLegacy"
                    }

                HomeLegacyFrom ->
                    { en = "Bulk transfer of trees from your legacy account"
                    , zh_hans = "%zh_hans:HomeLegacyFrom"
                    , zh_hant = "%zh_hant:HomeLegacyFrom"
                    , es = "%es:HomeLegacyFrom"
                    , fr = "%fr:HomeLegacyFrom"
                    , nl = "%nl:HomeLegacyFrom"
                    , sv = "%sv:HomeLegacyFrom"
                    }

                RecentDocuments ->
                    { en = "Recent Documents"
                    , zh_hans = "%zh_hans:RecentDocuments"
                    , zh_hant = "%zh_hant:RecentDocuments"
                    , es = "%es:RecentDocuments"
                    , fr = "%fr:RecentDocuments"
                    , nl = "%nl:RecentDocuments"
                    , sv = "%sv:RecentDocuments"
                    }

                LastUpdated ->
                    { en = "Last Updated"
                    , zh_hans = "%zh_hans:LastUpdated"
                    , zh_hant = "%zh_hant:LastUpdated"
                    , es = "%es:LastUpdated"
                    , fr = "%fr:LastUpdated"
                    , nl = "%nl:LastUpdated"
                    , sv = "%sv:LastUpdated"
                    }

                LastOpened ->
                    { en = "Last Opened"
                    , zh_hans = "%zh_hans:LastOpened"
                    , zh_hant = "%zh_hant:LastOpened"
                    , es = "%es:LastOpened"
                    , fr = "%fr:LastOpened"
                    , nl = "%nl:LastOpened"
                    , sv = "%sv:LastOpened"
                    }

                OpenOtherDocuments ->
                    { en = "Open Other Documents"
                    , zh_hans = "%zh_hans:OpenOtherDocuments"
                    , zh_hant = "%zh_hant:OpenOtherDocuments"
                    , es = "%es:OpenOtherDocuments"
                    , fr = "%fr:OpenOtherDocuments"
                    , nl = "%nl:OpenOtherDocuments"
                    , sv = "%sv:OpenOtherDocuments"
                    }

                DeleteDocument ->
                    { en = "Delete Document"
                    , zh_hans = "%zh_hans:DeleteDocument"
                    , zh_hant = "%zh_hant:DeleteDocument"
                    , es = "%es:DeleteDocument"
                    , fr = "%fr:DeleteDocument"
                    , nl = "%nl:DeleteDocument"
                    , sv = "%sv:DeleteDocument"
                    }

                RemoveFromList ->
                    { en = "Remove From List"
                    , zh_hans = "%zh_hans:RemoveFromList"
                    , zh_hant = "%zh_hant:RemoveFromList"
                    , es = "%es:RemoveFromList"
                    , fr = "%fr:RemoveFromList"
                    , nl = "%nl:RemoveFromList"
                    , sv = "%sv:RemoveFromList"
                    }

                NeverSaved ->
                    { en = "New Document..."
                    , zh_hans = "%zh_hans:NeverSaved"
                    , zh_hant = "%zh_hant:NeverSaved"
                    , es = "%es:NeverSaved"
                    , fr = "%fr:NeverSaved"
                    , nl = "%nl:NeverSaved"
                    , sv = "%sv:NeverSaved"
                    }

                UnsavedChanges ->
                    { en = "Unsaved Changes..."
                    , zh_hans = "%zh_hans:UnsavedChanges"
                    , zh_hant = "%zh_hant:UnsavedChanges"
                    , es = "%es:UnsavedChanges"
                    , fr = "%fr:UnsavedChanges"
                    , nl = "%nl:UnsavedChanges"
                    , sv = "%sv:UnsavedChanges"
                    }

                SavedInternally ->
                    { en = "Saved Offline"
                    , zh_hans = "%zh_hans:SavedInternally"
                    , zh_hant = "%zh_hant:SavedInternally"
                    , es = "%es:SavedInternally"
                    , fr = "%fr:SavedInternally"
                    , nl = "%nl:SavedInternally"
                    , sv = "%sv:SavedInternally"
                    }

                ChangesSaved ->
                    { en = "Saved"
                    , zh_hans = "%zh_hans:ChangesSaved"
                    , zh_hant = "%zh_hant:ChangesSaved"
                    , es = "%es:ChangesSaved"
                    , fr = "%fr:ChangesSaved"
                    , nl = "%nl:ChangesSaved"
                    , sv = "%sv:ChangesSaved"
                    }

                ChangesSynced ->
                    { en = "Synced"
                    , zh_hans = "%zh_hans:ChangesSynced"
                    , zh_hant = "%zh_hant:ChangesSynced"
                    , es = "%es:ChangesSynced"
                    , fr = "%fr:ChangesSynced"
                    , nl = "%nl:ChangesSynced"
                    , sv = "%sv:ChangesSynced"
                    }

                DatabaseError ->
                    { en = "Database Error..."
                    , zh_hans = "%zh_hans:DatabaseError"
                    , zh_hant = "%zh_hant:DatabaseError"
                    , es = "%es:DatabaseError"
                    , fr = "%fr:DatabaseError"
                    , nl = "%nl:DatabaseError"
                    , sv = "%sv:DatabaseError"
                    }

                LastSaved ->
                    { en = "Last saved"
                    , zh_hans = "%zh_hans:LastSaved"
                    , zh_hant = "%zh_hant:LastSaved"
                    , es = "%es:LastSaved"
                    , fr = "%fr:LastSaved"
                    , nl = "%nl:LastSaved"
                    , sv = "%sv:LastSaved"
                    }

                LastEdit ->
                    { en = "Last edit"
                    , zh_hans = "%zh_hans:LastEdit"
                    , zh_hant = "%zh_hant:LastEdit"
                    , es = "%es:LastEdit"
                    , fr = "%fr:LastEdit"
                    , nl = "%nl:LastEdit"
                    , sv = "%sv:LastEdit"
                    }

                KeyboardHelp ->
                    { en = "Keyboard Shortcuts Help"
                    , zh_hans = "%zh_hans:KeyboardHelp"
                    , zh_hant = "%zh_hant:KeyboardHelp"
                    , es = "%es:KeyboardHelp"
                    , fr = "%fr:KeyboardHelp"
                    , nl = "%nl:KeyboardHelp"
                    , sv = "%sv:KeyboardHelp"
                    }

                RestoreThisVersion ->
                    { en = "Restore this Version"
                    , zh_hans = "%zh_hans:RestoreThisVersion"
                    , zh_hant = "%zh_hant:RestoreThisVersion"
                    , es = "%es:RestoreThisVersion"
                    , fr = "%fr:RestoreThisVersion"
                    , nl = "%nl:RestoreThisVersion"
                    , sv = "%sv:RestoreThisVersion"
                    }

                EnterKey ->
                    { en = "Enter"
                    , zh_hans = "%zh_hans:EnterKey"
                    , zh_hant = "%zh_hant:EnterKey"
                    , es = "%es:EnterKey"
                    , fr = "%fr:EnterKey"
                    , nl = "%nl:EnterKey"
                    , sv = "%sv:EnterKey"
                    }

                EnterAction ->
                    { en = "to Edit"
                    , zh_hans = "%zh_hans:EnterAction"
                    , zh_hant = "%zh_hant:EnterAction"
                    , es = "%es:EnterAction"
                    , fr = "%fr:EnterAction"
                    , nl = "%nl:EnterAction"
                    , sv = "%sv:EnterAction"
                    }

                EditCardTitle ->
                    { en = "Edit Card (Enter)"
                    , zh_hans = "%zh_hans:EditCardTitle"
                    , zh_hant = "%zh_hant:EditCardTitle"
                    , es = "%es:EditCardTitle"
                    , fr = "%fr:EditCardTitle"
                    , nl = "%nl:EditCardTitle"
                    , sv = "%sv:EditCardTitle"
                    }

                ArrowsAction ->
                    { en = "to Navigate"
                    , zh_hans = "%zh_hans:ArrowsAction"
                    , zh_hant = "%zh_hant:ArrowsAction"
                    , es = "%es:ArrowsAction"
                    , fr = "%fr:ArrowsAction"
                    , nl = "%nl:ArrowsAction"
                    , sv = "%sv:ArrowsAction"
                    }

                AddChildAction ->
                    { en = "to Add Child"
                    , zh_hans = "%zh_hans:AddChildAction"
                    , zh_hant = "%zh_hant:AddChildAction"
                    , es = "%es:AddChildAction"
                    , fr = "%fr:AddChildAction"
                    , nl = "%nl:AddChildAction"
                    , sv = "%sv:AddChildAction"
                    }

                SplitChildAction ->
                    { en = "to Split Card to the Right"
                    , zh_hans = "%zh_hans:SplitChildAction"
                    , zh_hant = "%zh_hant:SplitChildAction"
                    , es = "%es:SplitChildAction"
                    , fr = "%fr:SplitChildAction"
                    , nl = "%nl:SplitChildAction"
                    , sv = "%sv:SplitChildAction"
                    }

                InsertChildTitle ->
                    { en = "Insert Child (Ctrl+L)"
                    , zh_hans = "%zh_hans:InsertChildTitle"
                    , zh_hant = "%zh_hant:InsertChildTitle"
                    , es = "%es:InsertChildTitle"
                    , fr = "%fr:InsertChildTitle"
                    , nl = "%nl:InsertChildTitle"
                    , sv = "%sv:InsertChildTitle"
                    }

                AddBelowAction ->
                    { en = "to Add Below"
                    , zh_hans = "%zh_hans:AddBelowAction"
                    , zh_hant = "%zh_hant:AddBelowAction"
                    , es = "%es:AddBelowAction"
                    , fr = "%fr:AddBelowAction"
                    , nl = "%nl:AddBelowAction"
                    , sv = "%sv:AddBelowAction"
                    }

                SplitBelowAction ->
                    { en = "to Split Card Down"
                    , zh_hans = "%zh_hans:SplitBelowAction"
                    , zh_hant = "%zh_hant:SplitBelowAction"
                    , es = "%es:SplitBelowAction"
                    , fr = "%fr:SplitBelowAction"
                    , nl = "%nl:SplitBelowAction"
                    , sv = "%sv:SplitBelowAction"
                    }

                MergeDownAction ->
                    { en = "to Merge into Next"
                    , zh_hans = "%zh_hans:MergeDownAction"
                    , zh_hant = "%zh_hant:MergeDownAction"
                    , es = "%es:MergeDownAction"
                    , fr = "%fr:MergeDownAction"
                    , nl = "%nl:MergeDownAction"
                    , sv = "%sv:MergeDownAction"
                    }

                InsertBelowTitle ->
                    { en = "Insert Below (Ctrl+J)"
                    , zh_hans = "%zh_hans:InsertBelowTitle"
                    , zh_hant = "%zh_hant:InsertBelowTitle"
                    , es = "%es:InsertBelowTitle"
                    , fr = "%fr:InsertBelowTitle"
                    , nl = "%nl:InsertBelowTitle"
                    , sv = "%sv:InsertBelowTitle"
                    }

                AddAboveAction ->
                    { en = "to Add Above"
                    , zh_hans = "%zh_hans:AddAboveAction"
                    , zh_hant = "%zh_hant:AddAboveAction"
                    , es = "%es:AddAboveAction"
                    , fr = "%fr:AddAboveAction"
                    , nl = "%nl:AddAboveAction"
                    , sv = "%sv:AddAboveAction"
                    }

                SplitUpwardAction ->
                    { en = "to Split Card Upward"
                    , zh_hans = "%zh_hans:SplitUpwardAction"
                    , zh_hant = "%zh_hant:SplitUpwardAction"
                    , es = "%es:SplitUpwardAction"
                    , fr = "%fr:SplitUpwardAction"
                    , nl = "%nl:SplitUpwardAction"
                    , sv = "%sv:SplitUpwardAction"
                    }

                MergeUpAction ->
                    { en = "to Merge into Previous"
                    , zh_hans = "%zh_hans:MergeUpAction"
                    , zh_hant = "%zh_hant:MergeUpAction"
                    , es = "%es:MergeUpAction"
                    , fr = "%fr:MergeUpAction"
                    , nl = "%nl:MergeUpAction"
                    , sv = "%sv:MergeUpAction"
                    }

                InsertAboveTitle ->
                    { en = "Insert Above (Ctrl+K)"
                    , zh_hans = "%zh_hans:InsertAboveTitle"
                    , zh_hant = "%zh_hant:InsertAboveTitle"
                    , es = "%es:InsertAboveTitle"
                    , fr = "%fr:InsertAboveTitle"
                    , nl = "%nl:InsertAboveTitle"
                    , sv = "%sv:InsertAboveTitle"
                    }

                ArrowKeys ->
                    { en = "(arrows)"
                    , zh_hans = "%zh_hans:ArrowKeys"
                    , zh_hant = "%zh_hant:ArrowKeys"
                    , es = "%es:ArrowKeys"
                    , fr = "%fr:ArrowKeys"
                    , nl = "%nl:ArrowKeys"
                    , sv = "%sv:ArrowKeys"
                    }

                MoveAction ->
                    { en = "to Move"
                    , zh_hans = "%zh_hans:MoveAction"
                    , zh_hant = "%zh_hant:MoveAction"
                    , es = "%es:MoveAction"
                    , fr = "%fr:MoveAction"
                    , nl = "%nl:MoveAction"
                    , sv = "%sv:MoveAction"
                    }

                Backspace ->
                    { en = "Backspace"
                    , zh_hans = "%zh_hans:Backspace"
                    , zh_hant = "%zh_hant:Backspace"
                    , es = "%es:Backspace"
                    , fr = "%fr:Backspace"
                    , nl = "%nl:Backspace"
                    , sv = "%sv:Backspace"
                    }

                DeleteAction ->
                    { en = "to Delete"
                    , zh_hans = "%zh_hans:DeleteAction"
                    , zh_hant = "%zh_hant:DeleteAction"
                    , es = "%es:DeleteAction"
                    , fr = "%fr:DeleteAction"
                    , nl = "%nl:DeleteAction"
                    , sv = "%sv:DeleteAction"
                    }

                DeleteCardTitle ->
                    { en = "Delete Card (Ctrl+Backspace)"
                    , zh_hans = "%zh_hans:DeleteCardTitle"
                    , zh_hant = "%zh_hant:DeleteCardTitle"
                    , es = "%es:DeleteCardTitle"
                    , fr = "%fr:DeleteCardTitle"
                    , nl = "%nl:DeleteCardTitle"
                    , sv = "%sv:DeleteCardTitle"
                    }

                FormattingGuide ->
                    { en = "More Formatting Options..."
                    , zh_hans = "%zh_hans:FormattingGuide"
                    , zh_hant = "%zh_hant:FormattingGuide"
                    , es = "%es:FormattingGuide"
                    , fr = "%fr:FormattingGuide"
                    , nl = "%nl:FormattingGuide"
                    , sv = "%sv:FormattingGuide"
                    }

                ForBold ->
                    { en = "for Bold"
                    , zh_hans = "%zh_hans:ForBold"
                    , zh_hant = "%zh_hant:ForBold"
                    , es = "%es:ForBold"
                    , fr = "%fr:ForBold"
                    , nl = "%nl:ForBold"
                    , sv = "%sv:ForBold"
                    }

                ForItalic ->
                    { en = "for Italic"
                    , zh_hans = "%zh_hans:ForItalic"
                    , zh_hant = "%zh_hant:ForItalic"
                    , es = "%es:ForItalic"
                    , fr = "%fr:ForItalic"
                    , nl = "%nl:ForItalic"
                    , sv = "%sv:ForItalic"
                    }

                ToSaveChanges ->
                    { en = "to Save Changes"
                    , zh_hans = "%zh_hans:ToSaveChanges"
                    , zh_hant = "%zh_hant:ToSaveChanges"
                    , es = "%es:ToSaveChanges"
                    , fr = "%fr:ToSaveChanges"
                    , nl = "%nl:ToSaveChanges"
                    , sv = "%sv:ToSaveChanges"
                    }

                SaveChangesTitle ->
                    { en = "Save Changes (Ctrl+Enter)"
                    , zh_hans = "%zh_hans:SaveChangesTitle"
                    , zh_hant = "%zh_hant:SaveChangesTitle"
                    , es = "%es:SaveChangesTitle"
                    , fr = "%fr:SaveChangesTitle"
                    , nl = "%nl:SaveChangesTitle"
                    , sv = "%sv:SaveChangesTitle"
                    }

                EscKey ->
                    { en = "Esc"
                    , zh_hans = "%zh_hans:EscKey"
                    , zh_hant = "%zh_hant:EscKey"
                    , es = "%es:EscKey"
                    , fr = "%fr:EscKey"
                    , nl = "%nl:EscKey"
                    , sv = "%sv:EscKey"
                    }

                AreYouSureCancel ->
                    { en = "Are you sure you want to undo your changes?"
                    , zh_hans = "%zh_hans:AreYouSureCancel"
                    , zh_hant = "%zh_hant:AreYouSureCancel"
                    , es = "%es:AreYouSureCancel"
                    , fr = "%fr:AreYouSureCancel"
                    , nl = "%nl:AreYouSureCancel"
                    , sv = "%sv:AreYouSureCancel"
                    }

                ToCancelChanges ->
                    { en = "to Cancel Changes"
                    , zh_hans = "%zh_hans:ToCancelChanges"
                    , zh_hant = "%zh_hant:ToCancelChanges"
                    , es = "%es:ToCancelChanges"
                    , fr = "%fr:ToCancelChanges"
                    , nl = "%nl:ToCancelChanges"
                    , sv = "%sv:ToCancelChanges"
                    }

                PressToSearch ->
                    { en = "Press '/' to search"
                    , zh_hans = "%zh_hans:PressToSearch"
                    , zh_hant = "%zh_hant:PressToSearch"
                    , es = "%es:PressToSearch"
                    , fr = "%fr:PressToSearch"
                    , nl = "%nl:PressToSearch"
                    , sv = "%sv:PressToSearch"
                    }

                HeadingFont ->
                    { en = "Heading Font"
                    , zh_hans = "%zh_hans:HeadingFont"
                    , zh_hant = "%zh_hant:HeadingFont"
                    , es = "%es:HeadingFont"
                    , fr = "%fr:HeadingFont"
                    , nl = "%nl:HeadingFont"
                    , sv = "%sv:HeadingFont"
                    }

                ContentFont ->
                    { en = "Content Font"
                    , zh_hans = "%zh_hans:ContentFont"
                    , zh_hant = "%zh_hant:ContentFont"
                    , es = "%es:ContentFont"
                    , fr = "%fr:ContentFont"
                    , nl = "%nl:ContentFont"
                    , sv = "%sv:ContentFont"
                    }

                EditingFont ->
                    { en = "Editing/Monospace Font"
                    , zh_hans = "%zh_hans:EditingFont"
                    , zh_hant = "%zh_hant:EditingFont"
                    , es = "%es:EditingFont"
                    , fr = "%fr:EditingFont"
                    , nl = "%nl:EditingFont"
                    , sv = "%sv:EditingFont"
                    }

                WordCountSession n ->
                    { en = numberPlural n "Session : %1 word" "Session : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountSession:0" "%zh_hans:WordCountSession:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountSession:0" "%zh_hant:WordCountSession:1"
                    , es = numberPlural n "%es:WordCountSession:0" "%es:WordCountSession:1"
                    , fr = numberPlural n "%fr:WordCountSession:0" "%fr:WordCountSession:1"
                    , nl = numberPlural n "%nl:WordCountSession:0" "%nl:WordCountSession:1"
                    , sv = numberPlural n "%sv:WordCountSession:0" "%sv:WordCountSession:1"
                    }

                WordCountTotal n ->
                    { en = numberPlural n "Total : %1 word" "Total : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountTotal:0" "%zh_hans:WordCountTotal:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountTotal:0" "%zh_hant:WordCountTotal:1"
                    , es = numberPlural n "%es:WordCountTotal:0" "%es:WordCountTotal:1"
                    , fr = numberPlural n "%fr:WordCountTotal:0" "%fr:WordCountTotal:1"
                    , nl = numberPlural n "%nl:WordCountTotal:0" "%nl:WordCountTotal:1"
                    , sv = numberPlural n "%sv:WordCountTotal:0" "%sv:WordCountTotal:1"
                    }

                WordCountCard n ->
                    { en = numberPlural n "Card : %1 word" "Card : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountCard:0" "%zh_hans:WordCountCard:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountCard:0" "%zh_hant:WordCountCard:1"
                    , es = numberPlural n "%es:WordCountCard:0" "%es:WordCountCard:1"
                    , fr = numberPlural n "%fr:WordCountCard:0" "%fr:WordCountCard:1"
                    , nl = numberPlural n "%nl:WordCountCard:0" "%nl:WordCountCard:1"
                    , sv = numberPlural n "%sv:WordCountCard:0" "%sv:WordCountCard:1"
                    }

                WordCountSubtree n ->
                    { en = numberPlural n "Subtree : %1 word" "Subtree : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountSubtree:0" "%zh_hans:WordCountSubtree:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountSubtree:0" "%zh_hant:WordCountSubtree:1"
                    , es = numberPlural n "%es:WordCountSubtree:0" "%es:WordCountSubtree:1"
                    , fr = numberPlural n "%fr:WordCountSubtree:0" "%fr:WordCountSubtree:1"
                    , nl = numberPlural n "%nl:WordCountSubtree:0" "%nl:WordCountSubtree:1"
                    , sv = numberPlural n "%sv:WordCountSubtree:0" "%sv:WordCountSubtree:1"
                    }

                WordCountGroup n ->
                    { en = numberPlural n "Group : %1 word" "Group : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountGroup:0" "%zh_hans:WordCountGroup:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountGroup:0" "%zh_hant:WordCountGroup:1"
                    , es = numberPlural n "%es:WordCountGroup:0" "%es:WordCountGroup:1"
                    , fr = numberPlural n "%fr:WordCountGroup:0" "%fr:WordCountGroup:1"
                    , nl = numberPlural n "%nl:WordCountGroup:0" "%nl:WordCountGroup:1"
                    , sv = numberPlural n "%sv:WordCountGroup:0" "%sv:WordCountGroup:1"
                    }

                WordCountColumn n ->
                    { en = numberPlural n "Column : %1 word" "Column : %1 words"
                    , zh_hans = numberPlural n "%zh_hans:WordCountColumn:0" "%zh_hans:WordCountColumn:1"
                    , zh_hant = numberPlural n "%zh_hant:WordCountColumn:0" "%zh_hant:WordCountColumn:1"
                    , es = numberPlural n "%es:WordCountColumn:0" "%es:WordCountColumn:1"
                    , fr = numberPlural n "%fr:WordCountColumn:0" "%fr:WordCountColumn:1"
                    , nl = numberPlural n "%nl:WordCountColumn:0" "%nl:WordCountColumn:1"
                    , sv = numberPlural n "%sv:WordCountColumn:0" "%sv:WordCountColumn:1"
                    }
    in
    case lang of
        En ->
            .en translationSet

        Zh_HANS ->
            .zh_hans translationSet

        Zh_HANT ->
            .zh_hant translationSet

        Es ->
            .es translationSet

        Fr ->
            .fr translationSet

        Nl ->
            .nl translationSet

        Sv ->
            .sv translationSet


timeDistInWords : Language -> Time.Posix -> Time.Posix -> String
timeDistInWords lang t1 t2 =
    case lang of
        En ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.en t1 t2

        Zh_HANS ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.en t1 t2

        Zh_HANT ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.en t1 t2

        Es ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.es t1 t2

        Fr ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.fr t1 t2

        Nl ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.en t1 t2

        Sv ->
            TimeDistance.inWordsWithConfig { withAffix = True } I18n.en t1 t2


dateFormat : Language -> Time.Posix -> String
dateFormat lang time =
    let
        formatString =
            "%B%e, %Y"
    in
    case lang of
        En ->
            format Time.Format.Config.Config_en_us.config formatString Time.utc time

        Zh_HANS ->
            format Time.Format.Config.Config_en_us.config formatString Time.utc time

        Zh_HANT ->
            format Time.Format.Config.Config_en_us.config formatString Time.utc time

        Es ->
            format Time.Format.Config.Config_es_es.config formatString Time.utc time

        Fr ->
            format Time.Format.Config.Config_fr_fr.config formatString Time.utc time

        Nl ->
            format Time.Format.Config.Config_nl_nl.config formatString Time.utc time

        Sv ->
            format Time.Format.Config.Config_sv_se.config formatString Time.utc time


languageDecoder : Decoder Language
languageDecoder =
    Json.map langFromString string


langFromString : String -> Language
langFromString str =
    case str of
        "en" ->
            En

        "zh" ->
            Zh_HANS

        "zh_HANS" ->
            Zh_HANS

        "zh_HANT" ->
            Zh_HANT

        "es" ->
            Es

        "fr" ->
            Fr

        "nl" ->
            Nl

        "sv" ->
            Sv

        _ ->
            En


langToString : Language -> String
langToString lang =
    case lang of
        En ->
            "en"

        Zh_HANS ->
            "zh_HANS"

        Zh_HANT ->
            "zh_HANT"

        Es ->
            "es"

        Fr ->
            "fr"

        Nl ->
            "nl"

        Sv ->
            "sv"
