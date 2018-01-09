-- Do not manually edit this file, it was auto-generated by Graphqelm
-- npm package version 1.0.1
-- Target elm package version 4.1.0
-- https://github.com/dillonkearns/graphqelm


module Github.InputObject.SubmitPullRequestReviewInput exposing (..)

import Github.Enum.PullRequestReviewEvent
import Github.InputObject
import Github.Interface
import Github.Object
import Github.Scalar
import Github.Union
import Graphqelm.Builder.Argument as Argument exposing (Argument)
import Graphqelm.Builder.Object as Object
import Graphqelm.Encode as Encode exposing (Value)
import Graphqelm.FieldDecoder as FieldDecoder exposing (FieldDecoder)
import Graphqelm.OptionalArgument exposing (OptionalArgument(Absent))
import Graphqelm.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Encode a SubmitPullRequestReviewInput into a value that can be used as an argument.
-}
encode : SubmitPullRequestReviewInput -> Value
encode input =
    Encode.maybeObject
        [ ( "clientMutationId", Encode.string |> Encode.optional input.clientMutationId ), ( "pullRequestReviewId", (\(Github.Scalar.Id raw) -> Encode.string raw) input.pullRequestReviewId |> Just ), ( "event", Encode.enum Github.Enum.PullRequestReviewEvent.toString input.event |> Just ), ( "body", Encode.string |> Encode.optional input.body ) ]


{-| Type for the SubmitPullRequestReviewInput input object.
-}
type alias SubmitPullRequestReviewInput =
    { clientMutationId : OptionalArgument String, pullRequestReviewId : Github.Scalar.Id, event : Github.Enum.PullRequestReviewEvent.PullRequestReviewEvent, body : OptionalArgument String }
