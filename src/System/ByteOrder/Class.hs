{-# language AllowAmbiguousTypes #-}
{-# language DataKinds #-}
{-# language GADTSyntax #-}
{-# language KindSignatures #-}
{-# language MagicHash #-}
{-# language RoleAnnotations #-}
{-# language ScopedTypeVariables #-}
{-# language TypeApplications #-}
{-# language UnboxedTuples #-}

module System.ByteOrder.Class
  ( FixedOrdering(..)
  , Bytes(..)
  ) where

import Data.Int (Int8,Int16,Int32,Int64)
import Data.Word (Word8,Word16,Word32,Word64)
import Data.Word (byteSwap16,byteSwap32,byteSwap64)
import GHC.ByteOrder (ByteOrder(..),targetByteOrder)
import GHC.ByteOrder (ByteOrder(BigEndian,LittleEndian))

-- | Types that are represented as a fixed-sized word. For these
-- types, the bytes can be swapped. The instances of this class
-- use byteswapping primitives and compile-time knowledge of native
-- endianness to provide portable endianness conversion functions.
class Bytes a where
  -- | Convert from a native-endian word to a big-endian word.
  toBigEndian :: a -> a
  -- | Convert from a native-endian word to a little-endian word.
  toLittleEndian :: a -> a

instance Bytes Word8 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = id
  toLittleEndian = id

instance Bytes Word16 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian -> byteSwap16
  toLittleEndian = case targetByteOrder of
    BigEndian -> byteSwap16
    LittleEndian -> id

instance Bytes Word32 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian -> byteSwap32
  toLittleEndian = case targetByteOrder of
    BigEndian -> byteSwap32
    LittleEndian -> id

instance Bytes Word64 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian -> byteSwap64
  toLittleEndian = case targetByteOrder of
    BigEndian -> byteSwap64
    LittleEndian -> id

instance Bytes Int8 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = id
  toLittleEndian = id

instance Bytes Int16 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian ->
        fromIntegral @Word16 @Int16
      . byteSwap16
      . fromIntegral @Int16 @Word16
  toLittleEndian = case targetByteOrder of
    BigEndian ->
        fromIntegral @Word16 @Int16
      . byteSwap16
      . fromIntegral @Int16 @Word16
    LittleEndian -> id

instance Bytes Int32 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian ->
        fromIntegral @Word32 @Int32
      . byteSwap32
      . fromIntegral @Int32 @Word32
  toLittleEndian = case targetByteOrder of
    BigEndian ->
        fromIntegral @Word32 @Int32
      . byteSwap32
      . fromIntegral @Int32 @Word32
    LittleEndian -> id

instance Bytes Int64 where
  {-# inline toBigEndian #-}
  {-# inline toLittleEndian #-}
  toBigEndian = case targetByteOrder of
    BigEndian -> id
    LittleEndian ->
        fromIntegral @Word64 @Int64
      . byteSwap64
      . fromIntegral @Int64 @Word64
  toLittleEndian = case targetByteOrder of
    BigEndian ->
        fromIntegral @Word64 @Int64
      . byteSwap64
      . fromIntegral @Int64 @Word64
    LittleEndian -> id

-- | A byte order that can be interpreted as a conversion function.
-- This class is effectively closed. The only instances are for
-- 'BigEndian' and 'LittleEndian'. It is not possible to write more
-- instances since there are no other inhabitants of 'ByteOrder'.
class FixedOrdering (b :: ByteOrder) where
  toFixedEndian :: Bytes a => a -> a

instance FixedOrdering 'LittleEndian where
  toFixedEndian = toLittleEndian

instance FixedOrdering 'BigEndian where
  toFixedEndian = toBigEndian
