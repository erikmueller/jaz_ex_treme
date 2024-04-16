defmodule JazExTreme do
  alias JazExTreme.Client

  @flow_temp "55"
  @return_temp "45"
  @norm_temp "-13"
  @id_air 3

  defp get_manufacturers() do
    case Client.get("https://www.waermepumpe.de/jazrechner/") do
      {:ok, %Tesla.Env{status: 200, body: html}} ->
        {:ok, document} = Floki.parse_document(html)

        document
        |> Floki.find("#wp_hersteller > option")
        |> Enum.map(fn {_, [{_, id}], [label]} -> [label, id] end)
        |> Enum.filter(fn
          [_, ""] ->
            false

          [_, id] ->
            {parsedId, _} = Integer.parse(id)
            parsedId > 0
        end)

      {:error, error} ->
        IO.puts("Error getting manufacturers")
        IO.inspect(error)
        exit(error)
    end
  end

  defp get_pumps(manufacturers, acc \\ [])

  defp get_pumps([], acc), do: acc

  defp get_pumps(manufacturers, acc) do
    pump_query =
      URI.encode_query(%{
        "type" => "3001",
        "tx_bwpjazrechner_jazrechner[action]" => "ajax",
        "tx_bwpjazrechner_jazrechner[controller]" => "Start"
      })

    [[manufacturer_label, manufacturer_id] | rest] = manufacturers

    IO.puts("Getting #{manufacturer_label} pumps")

    case Client.post(
           "https://www.waermepumpe.de/jazrechner/?#{pump_query}",
           %{
             # TODO loop
             "id_hersteller" => manufacturer_id,
             "id_typ" => @id_air,
             "tx_bwpjazrechner_jazrechner[sel]" => "getWaermepumpenByHerstellerAndTyp"
           }
         ) do
      {:ok, %Tesla.Env{status: 200, body: html}} ->
        {:ok, document} = Floki.parse_document(html)

        pumps =
          document
          |> Enum.map(fn {_tag, [{_attr, pump_id} | _rest], [pump_label]} ->
            ["#{manufacturer_label} #{pump_label}", manufacturer_id, pump_id]
          end)

        get_pumps(rest, pumps ++ acc)

      {:error, error} ->
        IO.puts("Error getting pumps for manufacturer #{manufacturer_label}")
        IO.inspect(error)
        get_pumps(rest, acc)
    end
  end

  defp calculate_jaz(pumps, acc \\ [])
  defp calculate_jaz([], acc), do: acc

  defp calculate_jaz(pumps, acc) do
    calc_jaz_query =
      URI.encode_query(%{
        "tx_bwpjazrechner_jazrechner[action]" => "ajax",
        "tx_bwpjazrechner_jazrechner[controller]" => "Start",
        "type" => "3001"
      })

    [[label, manufacturer_id, pump_id] | rest] = pumps

    case Client.post("https://www.waermepumpe.de/jazrechner/?#{calc_jaz_query}", %{
           "tx_bwpjazrechner_jazrechner[__referrer][@extension]" => "BwpJazrechner",
           "tx_bwpjazrechner_jazrechner[__referrer][@controller]" => "Start",
           "tx_bwpjazrechner_jazrechner[__referrer][@action]" => "index",
           "tx_bwpjazrechner_jazrechner[haus_heizgrenztemp]" => "15",
           "tx_bwpjazrechner_jazrechner[haus_vorlauftemp]" => @flow_temp,
           "tx_bwpjazrechner_jazrechner[haus_ruecklauftemp]" => @return_temp,
           "tx_bwpjazrechner_jazrechner[solar]" => "nein",
           "tx_bwpjazrechner_jazrechner[haus_aufwand_solaranlage]" => "2",
           "tx_bwpjazrechner_jazrechner[wp_hersteller]" => manufacturer_id,
           "tx_bwpjazrechner_jazrechner[wp_waermequelle]" => @id_air,
           "tx_bwpjazrechner_jazrechner[wp_waermepumpe]" => pump_id,
           "tx_bwpjazrechner_jazrechner[wp_zwischenkreiswaermetauscher]" => "nein",
           "tx_bwpjazrechner_jazrechner[wp_normaussentemp]" => @norm_temp,
           "tx_bwpjazrechner_jazrechner[wp_leistung_quellenpumpe]" => "0",
           "tx_bwpjazrechner_jazrechner[wp_betriebsweise]" => "1",
           "tx_bwpjazrechner_jazrechner[wp_normaussentemp_bivalenz]" => "-14",
           "tx_bwpjazrechner_jazrechner[wp_bivalenzpunkt]" => "0",
           "tx_bwpjazrechner_jazrechner[wp_solare_deckung]" => "0",
           "tx_bwpjazrechner_jazrechner[wp_TdV_m]" => "5",
           "tx_bwpjazrechner_jazrechner[wp_bauart]" => "fixed",
           "tx_bwpjazrechner_jazrechner[wp_id_pumpentyp]" => "2",
           "tx_bwpjazrechner_jazrechner[warmwasser_anteil]" => "18",
           "tx_bwpjazrechner_jazrechner[warmwasser_erzeuger]" => "1",
           "tx_bwpjazrechner_jazrechner[ww_wp_hersteller]" => "3",
           "tx_bwpjazrechner_jazrechner[wp_aussenluft_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[wp_raumluft_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[wp_abluft_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[wp_sole_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[wp_sole_wwspeicher_id_pumpentyp]" => "2",
           "tx_bwpjazrechner_jazrechner[wp_grundwasser_wwspeicher_zwischenkreiswaermetauscher]" =>
             "nein",
           "tx_bwpjazrechner_jazrechner[wp_grundwasser_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[wp_grundwasser_wwspeicher_id_pumpentyp]" => "2",
           "tx_bwpjazrechner_jazrechner[wp_dhx_wwspeicher_en16147_lastprofil]" => "L",
           "tx_bwpjazrechner_jazrechner[warmwasser_speichertemperatur]" => "50",
           "tx_bwpjazrechner_jazrechner[warmwasser_speichertyp]" => "wue_innen",
           "tx_bwpjazrechner_jazrechner[warmwasser_solare_deckung]" => "0",
           "tx_bwpjazrechner_jazrechner[sel]" => "calculateJAZ",
           "type" => "3001"
         }) do
      {:ok, %Tesla.Env{status: 200, body: json}} ->
        result = Jason.decode!(json)

        data = %{
          label: label,
          heat: result["JazWP"],
          water: result["JazWW"],
          combined: result["JazGesamt"]
        }

        IO.puts("Calculated JAZ for #{label} (WP #{data[:heat]})")

        calculate_jaz(rest, [data | acc])

      {:error, error} ->
        IO.puts("Error calculating JAZ for #{label}")
        IO.inspect(error)
        calculate_jaz(rest, acc)
    end
  end

  def run() do
    time =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()
      |> to_string()
      |> String.replace(" ", "-")

    result =
      get_manufacturers()
      |> tap(fn manufacturers -> IO.puts("\nGot #{Enum.count(manufacturers)} manufacturers\n") end)
      |> get_pumps()
      |> tap(fn pumps ->
        count = Enum.count(pumps)
        IO.puts("\nGot #{count} pumps, estimating ~#{count * 1.5 / 60} minutes to calculate.\n")
      end)
      |> calculate_jaz()
      |> Enum.sort(fn a, b -> a.heat < b.heat end)

    File.write!("./priv/#{@flow_temp}_#{@return_temp}_#{time}.json", result)
  end
end
