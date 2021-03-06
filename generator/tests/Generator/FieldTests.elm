module Generator.FieldTests exposing (all)

import Dict
import Expect
import Graphql.Generator.Context as Context exposing (Context)
import Graphql.Generator.Field as Field
import Graphql.Parser.CamelCaseName as CamelCaseName
import Graphql.Parser.ClassCaseName as ClassCaseName exposing (ClassCaseName)
import Graphql.Parser.Scalar as Scalar exposing (Scalar)
import Graphql.Parser.Type as Type exposing (TypeDefinition, TypeReference)
import Test exposing (..)


all : Test
all =
    describe "field generator"
        [ test "simple scalar converts for query" <|
            \() ->
                meField
                    |> Field.generateForObject (Context.context { query = "RootQueryObject", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "RootQueryObject")
                    |> Expect.equal
                        """me : SelectionSet String RootQuery
me =
      Object.selectionForField "String" "me" [] (Decode.string)
"""
        , test "converts for object" <|
            \() ->
                meField
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "Foo")
                    |> Expect.equal
                        """me : SelectionSet String Api.Object.Foo
me =
      Object.selectionForField "String" "me" [] (Decode.string)
"""
        , test "simple object with no args" <|
            \() ->
                { name = CamelCaseName.build "droid"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.ObjectRef "Droid") Type.NonNullable
                , args = []
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "RootQuery")
                    |> Expect.equal
                        """droid : SelectionSet decodesTo Api.Object.Droid -> SelectionSet decodesTo RootQuery
droid object_ =
      Object.selectionForCompositeField "droid" [] (object_) (identity)
"""
        , test "simple interface with no args" <|
            \() ->
                { name = CamelCaseName.build "hero"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.InterfaceRef "Character") Type.NonNullable
                , args = []
                }
                    |> Field.generateForObject
                        (Context.context
                            { query = "RootQuery"
                            , mutation = Nothing
                            , subscription = Nothing
                            , apiSubmodule = [ "Swapi" ]
                            , interfaces =
                                Dict.fromList
                                    [ ( "Character", [ ClassCaseName.build "Human", ClassCaseName.build "Droid" ] )
                                    ]
                            }
                        )
                        (ClassCaseName.build "RootQuery")
                    |> Expect.equal
                        """hero : SelectionSet decodesTo Swapi.Interface.Character -> SelectionSet decodesTo RootQuery
hero object_ =
      Object.selectionForCompositeField "hero" [] (object_) (identity)
"""
        , test "simple object with no args for object" <|
            \() ->
                { name = CamelCaseName.build "droid"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.ObjectRef "Droid") Type.NonNullable
                , args = []
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "Foo")
                    |> Expect.equal
                        """droid : SelectionSet decodesTo Api.Object.Droid -> SelectionSet decodesTo Api.Object.Foo
droid object_ =
      Object.selectionForCompositeField "droid" [] (object_) (identity)
"""
        , test "list of objects with no args" <|
            \() ->
                { name = CamelCaseName.build "droid"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.List (Type.TypeReference (Type.ObjectRef "Droid") Type.NonNullable)) Type.NonNullable
                , args = []
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "Foo")
                    |> Expect.equal
                        """droid : SelectionSet decodesTo Api.Object.Droid -> SelectionSet (List decodesTo) Api.Object.Foo
droid object_ =
      Object.selectionForCompositeField "droid" [] (object_) (identity >> Decode.list)
"""
        , test "with required args" <|
            \() ->
                { name = CamelCaseName.build "human"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.ObjectRef "Human") Type.NonNullable
                , args =
                    [ { name = CamelCaseName.build "id"
                      , description = Nothing
                      , typeRef = Type.TypeReference (Type.Scalar Scalar.String) Type.NonNullable
                      }
                    ]
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "RootQuery")
                    |> Expect.equal
                        """type alias HumanRequiredArguments = { id : String }

human : HumanRequiredArguments -> SelectionSet decodesTo Api.Object.Human -> SelectionSet decodesTo RootQuery
human requiredArgs object_ =
      Object.selectionForCompositeField "human" [ Argument.required "id" requiredArgs.id (Encode.string) ] (object_) (identity)
"""
        , test "with optional args" <|
            \() ->
                { name = CamelCaseName.build "menuItems"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.List (Type.TypeReference (Type.ObjectRef "MenuItem") Type.NonNullable)) Type.NonNullable
                , args =
                    [ { name = CamelCaseName.build "contains"
                      , description = Nothing
                      , typeRef = Type.TypeReference (Type.Scalar Scalar.String) Type.Nullable
                      }
                    ]
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "RootQuery")
                    |> Expect.equal
                        """type alias MenuItemsOptionalArguments = { contains : OptionalArgument String }

menuItems : (MenuItemsOptionalArguments -> MenuItemsOptionalArguments) -> SelectionSet decodesTo Api.Object.MenuItem -> SelectionSet (List decodesTo) RootQuery
menuItems fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { contains = Absent }

        optionalArgs =
            [ Argument.optional "contains" filledInOptionals.contains (Encode.string) ]
                |> List.filterMap identity
    in
      Object.selectionForCompositeField "menuItems" optionalArgs (object_) (identity >> Decode.list)
"""
        , test "normalizes reserved names" <|
            \() ->
                { name = CamelCaseName.build "type"
                , description = Nothing
                , typeRef = Type.TypeReference (Type.Scalar Scalar.String) Type.NonNullable
                , args = []
                }
                    |> Field.generateForObject (Context.context { query = "RootQuery", mutation = Nothing, subscription = Nothing, apiSubmodule = [ "Api" ], interfaces = Dict.empty }) (ClassCaseName.build "TreeEntry")
                    |> Expect.equal
                        """type_ : SelectionSet String Api.Object.TreeEntry
type_ =
      Object.selectionForField "String" "type" [] (Decode.string)
"""
        ]


meField : Type.Field
meField =
    { name = CamelCaseName.build "me"
    , description = Nothing
    , typeRef = Type.TypeReference (Type.Scalar Scalar.String) Type.NonNullable
    , args = []
    }
