{-# LANGUAGE KindSignatures, GADTs #-}
module Parser where

import Text.Parsec
import Text.Parsec.String
import qualified Text.Parsec.Token as T
import qualified Text.Parsec.Language as L
import Control.Applicative ((<*), (*>))
import Sq

type Var = String

data Query :: * -> * where
              AppExpr :: Query (a -> b) -> Query a -> Query b
              Bind  :: Query [a] -> F (a -> [b]) -> Query [b]
              Return :: Query a -> Query a
              UnionExpr :: Query a -> Query a -> Query a
              VarExpr :: Var -> Query a
              Guard :: Query Bool -> Query [()]
              Relation :: Ord a => Query a -> Binop -> Query a -> Query Bool
              StringLit ::  String -> Query String
              Modules :: Query [DbModule]
              Functions :: Query (DbModule -> [DbFunction])
              Name :: Named a => Query (a -> String)

data F :: * -> * where
          F :: Query a -> Query b -> F (a -> b)

data Binop
    = Eq
    | Lt
    | Lte
    | Gt
    | Gte
      deriving Show
{-
--sq :: T.LanguageDef
sqDef = L.emptyDef 
        { T.reservedNames = ["modules", "functions"]
        }

lexer = T.makeTokenParser sqDef

identifier = T.identifier lexer
symbol     = T.symbol lexer
reserved   = T.reserved lexer
braces     = T.braces lexer
whiteSpace = T.whiteSpace lexer
stringLiteral = T.stringLiteral lexer
comma      = T.comma lexer

query :: Parser Query
query = whiteSpace *> braces bind

var :: Parser Query
var = do v <- identifier
         return (VarExpr v)

app :: Parser Query
app = do f <- functions
         a <- identifier
         return (AppExpr f (VarExpr a))

-- query = { var <- query | query }

bind :: Parser Query
bind =  do 
  v <- try $ identifier <* bindop
  x <- bindable
  rest <- following
  return (Bind x (F v rest))

ret :: Parser Query
ret = vline *> Return `fmap` (app <|> var <|> query)

vline :: Parser String
vline = symbol "|"

bindop :: Parser String
bindop = symbol "<-"

bindable :: Parser Query
bindable = modules <|> app <|> query

following :: Parser Query
following = (comma *> (relation <|> bind)) <|> ret

modules :: Parser Query
modules = reserved "modules" `as` Modules

functions :: Parser Query
functions = reserved "functions" `as` Functions

name :: Parser Query
name = do 
  try $ do _ <- string "name" 
           notFollowedBy letter
  spaces
  v <- var
  return (AppExpr Name v)

arity :: Parser Query
arity = do 
  try $ do _ <- string "arity" 
           notFollowedBy letter
  spaces
  v <- var
  return (AppExpr Name v)

relation :: Parser Query
relation = do a1 <- (predicate <|> (fmap StringLit stringLiteral))
              rel <- relop
              a2 <- (predicate <|> (fmap StringLit stringLiteral))
              rest <- following
              return (Bind (Guard (Relation a1 rel a2)) (F "()" rest))

predicate :: Parser Query
predicate = name <|> arity

relop :: Parser Binop
relop = (eq <|> lt <|> gt) <* spaces

eq :: Parser Binop
eq = symbol "==" `as` Eq

lt :: Parser Binop
lt = symbol "<" `as` Lt

gt :: Parser Binop
gt = symbol ">" `as` Gt

as :: Parser a -> b -> Parser b
as p x = do { _ <- p; return x }
-}
