module Github.Object.RepositoryInvitation exposing (..)

import Github.Object
import Graphqelm.Builder.Argument as Argument exposing (Argument)
import Graphqelm.Builder.Object as Object
import Graphqelm.Encode as Encode exposing (Value)
import Graphqelm.FieldDecoder as FieldDecoder exposing (FieldDecoder)
import Graphqelm.OptionalArgument exposing (OptionalArgument(Absent))
import Graphqelm.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


selection : (a -> constructor) -> SelectionSet (a -> constructor) Github.Object.RepositoryInvitation
selection constructor =
    Object.object constructor


id : FieldDecoder String Github.Object.RepositoryInvitation
id =
    Object.fieldDecoder "id" [] Decode.string


invitee : SelectionSet invitee Github.Object.User -> FieldDecoder invitee Github.Object.RepositoryInvitation
invitee object =
    Object.selectionFieldDecoder "invitee" [] object identity


inviter : SelectionSet inviter Github.Object.User -> FieldDecoder inviter Github.Object.RepositoryInvitation
inviter object =
    Object.selectionFieldDecoder "inviter" [] object identity


repository : SelectionSet repository Github.Object.RepositoryInvitationRepository -> FieldDecoder (Maybe repository) Github.Object.RepositoryInvitation
repository object =
    Object.selectionFieldDecoder "repository" [] object (identity >> Decode.maybe)