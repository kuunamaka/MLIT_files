defmodule Remetis.ImportTask.UrbanArea do
  @moduledoc """
  Module to upsert the MLIT's urban area data to UrbanArea table.
  """

  import Ecto.Query, warn: false
  alias Remetis.UrbanArea
  alias Remeits.Repo

  @doc """
  Upsert data from
  https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-A09.html#
  """
  def upsert_urban_area(folder_path) do
    folder_path
    |> File.ls!()
    |> Enum.map(&Path.join([folder_path, &1]))

    # |> Enum.each(&upsert_data_in_year_directory())

    # mix task とrelese task を作ればおっけー！
  end

  defp upsert_urban_area_data(urban_area_path) do
    urban_area_path
    |> Path.join()
    |> load_geojson()
    |> parse_point_geojson()
  end

  # sobelow_skip ["Traversal.FileModule"]
  defp load_geojson(geojson_filepath) do
    geojson_filepath
    |> File.read!()
    |> Poison.decode!()
    |> Map.get("features")
  end

  # defp upsert_zoning_regulation(
  #        %{
  #          "geometry" => %{"type" => "Polygon", "coordinates" => polygon} = geometry
  #        } = attrs
  #      ) do
  #   attrs
  #   |> Map.replace("geometry", Map.replace(geometry, "coordinates", [polygon]))
  # end

  # defp upsert_zoning_regulation(%{"geometry" => nil}, _), do: nil

  defp parse_point_geojson(%{"features" => features}) do
    Enum.map(features, &parse_point_geojson_feature/1)
  end

  defp parse_point_geojson_feature(%{
         "properties" => %{
           "prefec_cd" => prefec_cd,
           "area_cd" => area_cd,
           "layer_no" => layer_no
         },
         "geometry" => %{"coordinates" => [longitude, latitude]}
       }) do
    %{
      prefec_cd: prefec_cd,
      area_cd: area_cd,
      layer_no: layer_no,
      longitude: longitude,
      latitude: latitude
    }
  end
end
